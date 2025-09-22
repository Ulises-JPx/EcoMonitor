#!/usr/bin/env python3
"""
Modelo de IA para análisis de datos de sensores IoT
Incluye predicción de valores futuros y detección de anomalías
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime, timedelta
import warnings
warnings.filterwarnings('ignore')

# Machine Learning
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.ensemble import IsolationForest
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, mean_absolute_error
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor

# Deep Learning para series temporales
try:
    import tensorflow as tf
    from tensorflow.keras.models import Sequential
    from tensorflow.keras.layers import LSTM, Dense, Dropout
    from tensorflow.keras.optimizers import Adam
    TENSORFLOW_AVAILABLE = True
except ImportError:
    TENSORFLOW_AVAILABLE = False
    print("⚠️ TensorFlow no está disponible. Usando modelos tradicionales.")

class SensorAIModel:
    def __init__(self, csv_file="Valores de Sensores.csv"):
        self.csv_file = csv_file
        self.data = None
        self.scaler = StandardScaler()
        self.label_encoders = {}
        self.models = {}
        self.anomaly_detector = None
        
    def load_and_preprocess_data(self):
        """Carga y preprocesa los datos del CSV"""
        print("🔄 Cargando datos del CSV...")
        
        # Cargar datos
        self.data = pd.read_csv(self.csv_file)
        
        # Convertir timestamp
        self.data['timestamp'] = pd.to_datetime(self.data['timestamp'])
        self.data = self.data.sort_values('timestamp').reset_index(drop=True)
        
        # Convertir números con coma decimal a punto decimal
        numeric_columns = ['tempC', 'hum%', 'mq135_raw', 'rs_r0', 'co2_ppm', 'ldr_raw', 'ldr_v', 'ldr_pct']
        for col in numeric_columns:
            self.data[col] = self.data[col].astype(str).str.replace(',', '.').astype(float)
        
        # Codificar variables categóricas
        categorical_columns = ['quality', 'light']
        for col in categorical_columns:
            le = LabelEncoder()
            self.data[f'{col}_encoded'] = le.fit_transform(self.data[col])
            self.label_encoders[col] = le
        
        print(f"✅ Datos cargados: {len(self.data)} registros")
        print(f"📊 Columnas: {list(self.data.columns)}")
        print(f"📅 Rango de fechas: {self.data['timestamp'].min()} a {self.data['timestamp'].max()}")
        
        return self.data
    
    def detect_anomalies(self, contamination=0.1):
        """Detecta anomalías en los datos usando Isolation Forest"""
        print("🔍 Detectando anomalías...")
        
        # Seleccionar columnas numéricas para detección de anomalías
        numeric_features = ['tempC', 'hum%', 'mq135_raw', 'rs_r0', 'co2_ppm', 'ldr_raw', 'ldr_v', 'ldr_pct']
        X = self.data[numeric_features].fillna(self.data[numeric_features].mean())
        
        # Entrenar modelo de detección de anomalías
        self.anomaly_detector = IsolationForest(contamination=contamination, random_state=42)
        anomaly_labels = self.anomaly_detector.fit_predict(X)
        
        # Agregar etiquetas de anomalía al DataFrame
        self.data['is_anomaly'] = anomaly_labels == -1
        self.data['anomaly_score'] = self.anomaly_detector.decision_function(X)
        
        n_anomalies = self.data['is_anomaly'].sum()
        print(f"🚨 Anomalías detectadas: {n_anomalies} ({n_anomalies/len(self.data)*100:.2f}%)")
        
        return self.data[self.data['is_anomaly']]
    
    def create_time_series_features(self, target_column='tempC', window_size=10):
        """Crea características de series temporales para predicción"""
        print(f"📈 Creando características de series temporales para {target_column}...")
        
        # Crear ventanas deslizantes
        for i in range(1, window_size + 1):
            self.data[f'{target_column}_lag_{i}'] = self.data[target_column].shift(i)
        
        # Estadísticas móviles
        self.data[f'{target_column}_rolling_mean'] = self.data[target_column].rolling(window=window_size).mean()
        self.data[f'{target_column}_rolling_std'] = self.data[target_column].rolling(window=window_size).std()
        
        # Características temporales
        self.data['hour'] = self.data['timestamp'].dt.hour
        self.data['day_of_week'] = self.data['timestamp'].dt.dayofweek
        self.data['day_of_year'] = self.data['timestamp'].dt.dayofyear
        
        # Eliminar filas con NaN
        self.data = self.data.dropna()
        
        print(f"✅ Características creadas. Datos finales: {len(self.data)} registros")
        
        return self.data
    
    def train_prediction_models(self, target_column='tempC'):
        """Entrena modelos de predicción"""
        print(f"🤖 Entrenando modelos de predicción para {target_column}...")
        
        # Preparar datos
        feature_columns = [col for col in self.data.columns if col not in [
            'timestamp', 'deviceId', 'quality', 'light', 'is_anomaly', 'anomaly_score',
            target_column, 'quality_encoded', 'light_encoded'
        ]]
        
        X = self.data[feature_columns].fillna(self.data[feature_columns].mean())
        y = self.data[target_column]
        
        # Dividir datos
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
        
        # Normalizar características
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        # Modelo 1: Regresión Lineal
        lr_model = LinearRegression()
        lr_model.fit(X_train_scaled, y_train)
        lr_pred = lr_model.predict(X_test_scaled)
        lr_mse = mean_squared_error(y_test, lr_pred)
        
        # Modelo 2: Random Forest
        rf_model = RandomForestRegressor(n_estimators=100, random_state=42)
        rf_model.fit(X_train_scaled, y_train)
        rf_pred = rf_model.predict(X_test_scaled)
        rf_mse = mean_squared_error(y_test, rf_pred)
        
        # Guardar modelos
        self.models[target_column] = {
            'linear_regression': lr_model,
            'random_forest': rf_model,
            'feature_columns': feature_columns,
            'test_mse': {'lr': lr_mse, 'rf': rf_mse}
        }
        
        print(f"✅ Modelos entrenados para {target_column}:")
        print(f"   - Regresión Lineal MSE: {lr_mse:.4f}")
        print(f"   - Random Forest MSE: {rf_mse:.4f}")
        
        return self.models[target_column]
    
    def train_lstm_model(self, target_column='tempC', sequence_length=60):
        """Entrena modelo LSTM para predicción de series temporales"""
        if not TENSORFLOW_AVAILABLE:
            print("⚠️ TensorFlow no disponible. Saltando modelo LSTM.")
            return None
        
        print(f"🧠 Entrenando modelo LSTM para {target_column}...")
        
        # Preparar datos para LSTM
        data_values = self.data[target_column].values.reshape(-1, 1)
        data_scaled = self.scaler.fit_transform(data_values)
        
        # Crear secuencias
        X, y = [], []
        for i in range(sequence_length, len(data_scaled)):
            X.append(data_scaled[i-sequence_length:i, 0])
            y.append(data_scaled[i, 0])
        
        X, y = np.array(X), np.array(y)
        
        # Dividir datos
        split = int(0.8 * len(X))
        X_train, X_test = X[:split], X[split:]
        y_train, y_test = y[:split], y[split:]
        
        # Reshape para LSTM
        X_train = X_train.reshape((X_train.shape[0], X_train.shape[1], 1))
        X_test = X_test.reshape((X_test.shape[0], X_test.shape[1], 1))
        
        # Crear modelo LSTM
        model = Sequential([
            LSTM(50, return_sequences=True, input_shape=(sequence_length, 1)),
            Dropout(0.2),
            LSTM(50, return_sequences=False),
            Dropout(0.2),
            Dense(25),
            Dense(1)
        ])
        
        model.compile(optimizer=Adam(learning_rate=0.001), loss='mse')
        
        # Entrenar modelo
        history = model.fit(X_train, y_train, 
                          batch_size=32, 
                          epochs=50, 
                          validation_data=(X_test, y_test),
                          verbose=0)
        
        # Evaluar modelo
        y_pred = model.predict(X_test)
        mse = mean_squared_error(y_test, y_pred)
        
        print(f"✅ Modelo LSTM entrenado. MSE: {mse:.4f}")
        
        return {
            'model': model,
            'scaler': self.scaler,
            'sequence_length': sequence_length,
            'mse': mse,
            'history': history
        }
    
    def predict_future_values(self, target_column='tempC', hours_ahead=24):
        """Predice valores futuros"""
        print(f"🔮 Prediciendo valores futuros para {target_column} ({hours_ahead} horas)...")
        
        if target_column not in self.models:
            print(f"❌ Modelo no encontrado para {target_column}")
            return None
        
        # Usar el mejor modelo (Random Forest generalmente)
        model = self.models[target_column]['random_forest']
        feature_columns = self.models[target_column]['feature_columns']
        
        # Obtener los últimos valores conocidos
        last_values = self.data[feature_columns].iloc[-1:].fillna(self.data[feature_columns].mean())
        
        predictions = []
        current_values = last_values.copy()
        
        for i in range(hours_ahead):
            # Predecir siguiente valor
            pred_scaled = model.predict(self.scaler.transform(current_values))
            predictions.append(pred_scaled[0])
            
            # Actualizar valores para siguiente predicción
            if f'{target_column}_lag_1' in current_values.columns:
                current_values[f'{target_column}_lag_1'] = pred_scaled[0]
            
            # Actualizar otras características si es necesario
            if f'{target_column}_rolling_mean' in current_values.columns:
                current_values[f'{target_column}_rolling_mean'] = np.mean(predictions[-10:])
        
        # Crear DataFrame con predicciones
        future_times = pd.date_range(
            start=self.data['timestamp'].iloc[-1] + timedelta(minutes=1),
            periods=hours_ahead,
            freq='1min'
        )
        
        future_df = pd.DataFrame({
            'timestamp': future_times,
            f'{target_column}_predicted': predictions
        })
        
        print(f"✅ Predicciones generadas para {len(future_df)} puntos futuros")
        
        return future_df
    
    def visualize_results(self, target_column='tempC', anomalies_df=None, predictions_df=None):
        """Visualiza los resultados del análisis"""
        print("📊 Generando visualizaciones...")
        
        fig, axes = plt.subplots(2, 2, figsize=(15, 10))
        fig.suptitle(f'Análisis de IA para {target_column}', fontsize=16)
        
        # 1. Serie temporal con anomalías
        axes[0, 0].plot(self.data['timestamp'], self.data[target_column], alpha=0.7, label='Datos normales')
        if anomalies_df is not None and not anomalies_df.empty:
            axes[0, 0].scatter(anomalies_df['timestamp'], anomalies_df[target_column], 
                             color='red', alpha=0.7, label='Anomalías', s=20)
        axes[0, 0].set_title('Serie Temporal con Anomalías')
        axes[0, 0].set_ylabel(target_column)
        axes[0, 0].legend()
        axes[0, 0].tick_params(axis='x', rotation=45)
        
        # 2. Distribución de valores
        axes[0, 1].hist(self.data[target_column], bins=50, alpha=0.7, edgecolor='black')
        axes[0, 1].set_title('Distribución de Valores')
        axes[0, 1].set_xlabel(target_column)
        axes[0, 1].set_ylabel('Frecuencia')
        
        # 3. Predicciones futuras
        if predictions_df is not None:
            axes[1, 0].plot(self.data['timestamp'], self.data[target_column], alpha=0.7, label='Datos históricos')
            axes[1, 0].plot(predictions_df['timestamp'], predictions_df[f'{target_column}_predicted'], 
                           color='red', alpha=0.8, label='Predicciones')
            axes[1, 0].set_title('Predicciones Futuras')
            axes[1, 0].set_ylabel(target_column)
            axes[1, 0].legend()
            axes[1, 0].tick_params(axis='x', rotation=45)
        else:
            axes[1, 0].text(0.5, 0.5, 'No hay predicciones disponibles', 
                           ha='center', va='center', transform=axes[1, 0].transAxes)
            axes[1, 0].set_title('Predicciones Futuras')
        
        # 4. Correlaciones
        numeric_cols = ['tempC', 'hum%', 'co2_ppm', 'ldr_raw', 'ldr_v']
        corr_matrix = self.data[numeric_cols].corr()
        sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', center=0, ax=axes[1, 1])
        axes[1, 1].set_title('Matriz de Correlación')
        
        plt.tight_layout()
        plt.savefig(f'sensor_ai_analysis_{target_column}.png', dpi=300, bbox_inches='tight')
        plt.show()
        
        print("✅ Visualizaciones guardadas como 'sensor_ai_analysis_{}.png'".format(target_column))
    
    def generate_report(self, target_column='tempC'):
        """Genera un reporte completo del análisis"""
        print(f"\n📋 GENERANDO REPORTE PARA {target_column.upper()}")
        print("=" * 50)
        
        # Estadísticas básicas
        print(f"📊 Estadísticas básicas:")
        print(f"   - Total de registros: {len(self.data)}")
        print(f"   - Valor promedio: {self.data[target_column].mean():.2f}")
        print(f"   - Valor mínimo: {self.data[target_column].min():.2f}")
        print(f"   - Valor máximo: {self.data[target_column].max():.2f}")
        print(f"   - Desviación estándar: {self.data[target_column].std():.2f}")
        
        # Anomalías
        if 'is_anomaly' in self.data.columns:
            n_anomalies = self.data['is_anomaly'].sum()
            print(f"\n🚨 Anomalías detectadas:")
            print(f"   - Cantidad: {n_anomalies}")
            print(f"   - Porcentaje: {n_anomalies/len(self.data)*100:.2f}%")
        
        # Modelos de predicción
        if target_column in self.models:
            print(f"\n🤖 Modelos de predicción:")
            for model_name, mse in self.models[target_column]['test_mse'].items():
                print(f"   - {model_name}: MSE = {mse:.4f}")
        
        print("\n✅ Reporte generado exitosamente")

def main():
    """Función principal"""
    print("🚀 Iniciando análisis de IA para datos de sensores IoT")
    print("=" * 60)
    
    # Crear instancia del modelo
    ai_model = SensorAIModel("Valores de Sensores.csv")
    
    # Cargar y preprocesar datos
    data = ai_model.load_and_preprocess_data()
    
    # Detectar anomalías
    anomalies = ai_model.detect_anomalies(contamination=0.05)  # 5% de anomalías
    
    # Analizar diferentes sensores
    sensors_to_analyze = ['tempC', 'hum%', 'co2_ppm', 'ldr_raw']
    
    for sensor in sensors_to_analyze:
        print(f"\n🔬 Analizando sensor: {sensor}")
        print("-" * 30)
        
        # Crear características de series temporales
        ai_model.create_time_series_features(target_column=sensor, window_size=10)
        
        # Entrenar modelos de predicción
        ai_model.train_prediction_models(target_column=sensor)
        
        # Generar predicciones futuras
        predictions = ai_model.predict_future_values(target_column=sensor, hours_ahead=24)
        
        # Visualizar resultados
        ai_model.visualize_results(target_column=sensor, anomalies_df=anomalies, predictions_df=predictions)
        
        # Generar reporte
        ai_model.generate_report(target_column=sensor)
    
    print("\n🎉 Análisis completado exitosamente!")
    print("📁 Archivos generados:")
    print("   - sensor_ai_analysis_*.png (visualizaciones)")
    print("   - Reportes en consola")

if __name__ == "__main__":
    main()
