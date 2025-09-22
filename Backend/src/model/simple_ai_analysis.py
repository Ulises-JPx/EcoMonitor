#!/usr/bin/env python3
"""
Análisis de IA simple para datos de sensores IoT
Versión simplificada sin dependencias pesadas
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime, timedelta
import warnings
warnings.filterwarnings('ignore')

# Machine Learning básico
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import IsolationForest, RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, mean_absolute_error
from sklearn.linear_model import LinearRegression

class SimpleSensorAI:
    def __init__(self, csv_file="Valores de Sensores.csv"):
        self.csv_file = csv_file
        self.data = None
        self.scaler = StandardScaler()
        
    def load_data(self):
        """Carga y preprocesa los datos"""
        print("🔄 Cargando datos...")
        
        # Cargar CSV
        self.data = pd.read_csv(self.csv_file)
        
        # Convertir timestamp (manejar diferentes formatos)
        self.data['timestamp'] = pd.to_datetime(self.data['timestamp'], errors='coerce')
        # Eliminar filas con timestamps inválidos
        self.data = self.data.dropna(subset=['timestamp'])
        self.data = self.data.sort_values('timestamp').reset_index(drop=True)
        
        # Convertir números con coma decimal
        numeric_columns = ['tempC', 'hum%', 'mq135_raw', 'rs_r0', 'co2_ppm', 'ldr_raw', 'ldr_v', 'ldr_pct']
        for col in numeric_columns:
            self.data[col] = self.data[col].astype(str).str.replace(',', '.').astype(float)
        
        print(f"✅ Datos cargados: {len(self.data)} registros")
        print(f"📅 Rango: {self.data['timestamp'].min()} a {self.data['timestamp'].max()}")
        
        return self.data
    
    def detect_anomalies(self, sensor='tempC'):
        """Detecta anomalías en un sensor específico"""
        print(f"🔍 Detectando anomalías en {sensor}...")
        
        # Usar múltiples sensores para mejor detección
        features = ['tempC', 'hum%', 'co2_ppm', 'ldr_raw']
        X = self.data[features].fillna(self.data[features].mean())
        
        # Modelo de detección de anomalías
        anomaly_detector = IsolationForest(contamination=0.1, random_state=42)
        anomaly_labels = anomaly_detector.fit_predict(X)
        
        # Agregar al DataFrame
        self.data['is_anomaly'] = anomaly_labels == -1
        self.data['anomaly_score'] = anomaly_detector.decision_function(X)
        
        anomalies = self.data[self.data['is_anomaly']]
        print(f"🚨 Anomalías detectadas: {len(anomalies)} ({len(anomalies)/len(self.data)*100:.1f}%)")
        
        return anomalies
    
    def predict_future(self, sensor='tempC', hours=24):
        """Predice valores futuros usando Random Forest"""
        print(f"🔮 Prediciendo {sensor} para las próximas {hours} horas...")
        
        # Asegurar que timestamp sea datetime
        if not pd.api.types.is_datetime64_any_dtype(self.data['timestamp']):
            self.data['timestamp'] = pd.to_datetime(self.data['timestamp'], errors='coerce')
        
        # Crear características temporales
        self.data['hour'] = self.data['timestamp'].dt.hour
        self.data['minute'] = self.data['timestamp'].dt.minute
        self.data['day_of_week'] = self.data['timestamp'].dt.dayofweek
        
        # Crear lags (valores anteriores)
        for i in range(1, 6):
            self.data[f'{sensor}_lag_{i}'] = self.data[sensor].shift(i)
        
        # Media móvil
        self.data[f'{sensor}_ma_5'] = self.data[sensor].rolling(window=5).mean()
        self.data[f'{sensor}_ma_10'] = self.data[sensor].rolling(window=10).mean()
        
        # Eliminar NaN
        data_clean = self.data.dropna()
        
        # Preparar datos para entrenamiento
        feature_cols = [col for col in data_clean.columns if col not in [
            'timestamp', 'deviceId', 'quality', 'light', 'is_anomaly', 'anomaly_score', sensor
        ]]
        
        X = data_clean[feature_cols]
        y = data_clean[sensor]
        
        # Dividir datos
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
        
        # Entrenar modelo
        model = RandomForestRegressor(n_estimators=100, random_state=42)
        model.fit(X_train, y_train)
        
        # Evaluar
        y_pred = model.predict(X_test)
        mse = mean_squared_error(y_test, y_pred)
        mae = mean_absolute_error(y_test, y_pred)
        
        print(f"📊 Precisión del modelo:")
        print(f"   - MSE: {mse:.4f}")
        print(f"   - MAE: {mae:.4f}")
        
        # Generar predicciones futuras
        last_row = data_clean.iloc[-1:].copy()
        predictions = []
        
        for i in range(hours):
            # Predecir siguiente valor
            pred = model.predict(last_row[feature_cols])[0]
            predictions.append(pred)
            
            # Actualizar lags para siguiente predicción
            for j in range(4, 0, -1):
                last_row[f'{sensor}_lag_{j+1}'] = last_row[f'{sensor}_lag_{j}']
            last_row[f'{sensor}_lag_1'] = pred
            
            # Actualizar medias móviles
            last_row[f'{sensor}_ma_5'] = np.mean(predictions[-5:]) if len(predictions) >= 5 else pred
            last_row[f'{sensor}_ma_10'] = np.mean(predictions[-10:]) if len(predictions) >= 10 else pred
        
        # Crear DataFrame con predicciones
        future_times = pd.date_range(
            start=self.data['timestamp'].iloc[-1] + timedelta(minutes=1),
            periods=hours,
            freq='1min'
        )
        
        future_df = pd.DataFrame({
            'timestamp': future_times,
            f'{sensor}_predicted': predictions
        })
        
        return future_df, model
    
    def analyze_patterns(self, sensor='tempC'):
        """Analiza patrones en los datos"""
        print(f"📈 Analizando patrones en {sensor}...")
        
        # Asegurar que timestamp sea datetime
        if not pd.api.types.is_datetime64_any_dtype(self.data['timestamp']):
            self.data['timestamp'] = pd.to_datetime(self.data['timestamp'], errors='coerce')
        
        # Estadísticas por hora
        self.data['hour'] = self.data['timestamp'].dt.hour
        hourly_stats = self.data.groupby('hour')[sensor].agg(['mean', 'std', 'min', 'max'])
        
        # Estadísticas por día de la semana
        self.data['day_of_week'] = self.data['timestamp'].dt.dayofweek
        daily_stats = self.data.groupby('day_of_week')[sensor].agg(['mean', 'std'])
        
        print(f"📊 Estadísticas por hora:")
        print(hourly_stats.round(2))
        
        print(f"\n📊 Estadísticas por día de la semana:")
        print(daily_stats.round(2))
        
        return hourly_stats, daily_stats
    
    def create_visualizations(self, sensor='tempC', anomalies=None, predictions=None):
        """Crea visualizaciones del análisis"""
        print("📊 Generando gráficos...")
        
        fig, axes = plt.subplots(2, 2, figsize=(15, 10))
        fig.suptitle(f'Análisis de IA para {sensor}', fontsize=16)
        
        # 1. Serie temporal con anomalías
        axes[0, 0].plot(self.data['timestamp'], self.data[sensor], alpha=0.7, linewidth=1)
        if anomalies is not None and not anomalies.empty:
            axes[0, 0].scatter(anomalies['timestamp'], anomalies[sensor], 
                             color='red', alpha=0.8, s=20, label='Anomalías')
            axes[0, 0].legend()
        axes[0, 0].set_title('Serie Temporal con Anomalías')
        axes[0, 0].set_ylabel(sensor)
        axes[0, 0].tick_params(axis='x', rotation=45)
        
        # 2. Distribución
        axes[0, 1].hist(self.data[sensor], bins=50, alpha=0.7, edgecolor='black')
        axes[0, 1].set_title('Distribución de Valores')
        axes[0, 1].set_xlabel(sensor)
        axes[0, 1].set_ylabel('Frecuencia')
        
        # 3. Predicciones
        if predictions is not None:
            axes[1, 0].plot(self.data['timestamp'], self.data[sensor], alpha=0.7, label='Histórico')
            axes[1, 0].plot(predictions['timestamp'], predictions[f'{sensor}_predicted'], 
                           color='red', alpha=0.8, label='Predicciones')
            axes[1, 0].set_title('Predicciones Futuras')
            axes[1, 0].set_ylabel(sensor)
            axes[1, 0].legend()
            axes[1, 0].tick_params(axis='x', rotation=45)
        else:
            axes[1, 0].text(0.5, 0.5, 'Sin predicciones', ha='center', va='center')
            axes[1, 0].set_title('Predicciones Futuras')
        
        # 4. Patrones por hora
        hourly_avg = self.data.groupby(self.data['timestamp'].dt.hour)[sensor].mean()
        axes[1, 1].plot(hourly_avg.index, hourly_avg.values, marker='o')
        axes[1, 1].set_title('Patrón Promedio por Hora')
        axes[1, 1].set_xlabel('Hora del día')
        axes[1, 1].set_ylabel(f'{sensor} promedio')
        axes[1, 1].grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(f'simple_ai_analysis_{sensor}.png', dpi=300, bbox_inches='tight')
        plt.show()
        
        print(f"✅ Gráfico guardado como 'simple_ai_analysis_{sensor}.png'")
    
    def generate_summary_report(self, sensor='tempC'):
        """Genera un reporte resumen"""
        print(f"\n📋 REPORTE DE ANÁLISIS PARA {sensor.upper()}")
        print("=" * 50)
        
        # Estadísticas básicas
        stats = self.data[sensor].describe()
        print(f"📊 Estadísticas básicas:")
        print(f"   - Promedio: {stats['mean']:.2f}")
        print(f"   - Mediana: {stats['50%']:.2f}")
        print(f"   - Mínimo: {stats['min']:.2f}")
        print(f"   - Máximo: {stats['max']:.2f}")
        print(f"   - Desviación: {stats['std']:.2f}")
        
        # Anomalías
        if 'is_anomaly' in self.data.columns:
            n_anomalies = self.data['is_anomaly'].sum()
            print(f"\n🚨 Anomalías:")
            print(f"   - Detectadas: {n_anomalies}")
            print(f"   - Porcentaje: {n_anomalies/len(self.data)*100:.1f}%")
        
        # Patrones temporales
        print(f"\n⏰ Patrones temporales:")
        hourly_avg = self.data.groupby(self.data['timestamp'].dt.hour)[sensor].mean()
        min_hour = hourly_avg.idxmin()
        max_hour = hourly_avg.idxmax()
        print(f"   - Hora más baja: {min_hour}:00 ({hourly_avg[min_hour]:.2f})")
        print(f"   - Hora más alta: {max_hour}:00 ({hourly_avg[max_hour]:.2f})")
        
        print(f"\n✅ Análisis completado para {sensor}")

def main():
    """Función principal"""
    print("🚀 Análisis de IA Simple para Sensores IoT")
    print("=" * 50)
    
    # Crear instancia
    ai = SimpleSensorAI("Valores de Sensores.csv")
    
    # Cargar datos
    data = ai.load_data()
    
    # Analizar sensores principales
    sensors = ['tempC', 'hum%', 'co2_ppm', 'ldr_raw']
    
    for sensor in sensors:
        print(f"\n🔬 Analizando {sensor}...")
        print("-" * 30)
        
        # Detectar anomalías
        anomalies = ai.detect_anomalies(sensor)
        
        # Analizar patrones
        ai.analyze_patterns(sensor)
        
        # Generar predicciones
        predictions, model = ai.predict_future(sensor, hours=24)
        
        # Crear visualizaciones
        ai.create_visualizations(sensor, anomalies, predictions)
        
        # Generar reporte
        ai.generate_summary_report(sensor)
    
    print(f"\n🎉 Análisis completado!")
    print(f"📁 Archivos generados:")
    print(f"   - simple_ai_analysis_*.png")

if __name__ == "__main__":
    main()
