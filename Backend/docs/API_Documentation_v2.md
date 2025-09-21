# API de Sensores IoT - Documentación de Rutas v2

## 📋 Información General

- **Base URL**: `http://localhost:5000`
- **Formato**: JSON
- **Método**: GET
- **Archivo de datos**: `Valores de Sensores - David - data.csv`
- **Total de registros**: 4,266 mediciones

## 🛠️ Endpoints Disponibles

### 1. Documentación Principal
```
GET /
```
**Descripción**: Página de inicio con documentación completa de la API

**Respuesta**:
```json
{
  "message": "API de Sensores IoT - Valores de Sensores",
  "archivo_datos": "Valores de Sensores - David - data.csv",
  "total_sensores": 10,
  "sensores_disponibles": {
    "temperatura": {
      "columna": "tempC",
      "unidad": "°C",
      "descripcion": "Temperatura en grados Celsius",
      "tipo": "numeric"
    },
    "humedad": {
      "columna": "hum%",
      "unidad": "%",
      "descripcion": "Humedad relativa",
      "tipo": "numeric"
    }
  },
  "endpoint_principal": "/datos",
  "filtros_disponibles": {
    "sensor": "Sensor específico: temperatura, humedad, co2, calidad_aire, luz_raw, luz_voltaje, luz_porcentaje, luz_estado, mq135_raw, rs_r0",
    "device_id": "ID del dispositivo (ej: esp32-1)",
    "start_date": "Fecha inicio (formato: YYYY-MM-DD o YYYY-MM-DDTHH:MM:SS)",
    "end_date": "Fecha fin (formato: YYYY-MM-DD o YYYY-MM-DDTHH:MM:SS)"
  }
}
```

### 2. Obtener Datos (Endpoint Principal)
```
GET /datos
```
**Descripción**: Obtiene datos de sensores con filtros opcionales

#### Parámetros de Query (Opcionales)

| Parámetro | Tipo | Descripción | Ejemplo |
|-----------|------|-------------|---------|
| `sensor` | string | Sensor específico a consultar | `temperatura`, `humedad`, `co2`, etc. |
| `device_id` | string | ID del dispositivo | `esp32-1` |
| `start_date` | string | Fecha de inicio del filtro | `2025-09-18` o `2025-09-18T00:00:00` |
| `end_date` | string | Fecha de fin del filtro | `2025-09-19` o `2025-09-19T23:59:59` |

#### Ejemplos de Uso

**1. Obtener todos los datos:**
```
GET /datos
```

**2. Obtener solo datos de temperatura:**
```
GET /datos?sensor=temperatura
```

**3. Obtener solo datos de humedad:**
```
GET /datos?sensor=humedad
```

**4. Obtener datos de un dispositivo específico:**
```
GET /datos?device_id=esp32-1
```

**5. Obtener datos desde una fecha específica:**
```
GET /datos?start_date=2025-09-18
```

**6. Obtener datos en un rango de fechas:**
```
GET /datos?start_date=2025-09-18&end_date=2025-09-19
```

**7. Obtener datos de CO2 con filtro de fecha:**
```
GET /datos?sensor=co2&start_date=2025-09-18T00:00:00
```

**8. Combinar múltiples filtros:**
```
GET /datos?sensor=humedad&device_id=esp32-1&start_date=2025-09-18T00:00:00
```

### 3. Listar Sensores
```
GET /sensores
```
**Descripción**: Lista todos los sensores disponibles con su información

**Respuesta**:
```json
{
  "sensores": {
    "temperatura": {
      "columna": "tempC",
      "unidad": "°C",
      "descripcion": "Temperatura en grados Celsius",
      "tipo": "numeric"
    }
  },
  "total_sensores": 10,
  "sensores_numericos": ["temperatura", "humedad", "co2", "luz_raw", "luz_voltaje", "luz_porcentaje", "mq135_raw", "rs_r0"],
  "sensores_categoricos": ["calidad_aire", "luz_estado"]
}
```

### 4. Listar Dispositivos
```
GET /dispositivos
```
**Descripción**: Lista todos los dispositivos disponibles

**Respuesta**:
```json
{
  "dispositivos": ["esp32-1"],
  "total_dispositivos": 1
}
```

## 🌡️ Sensores Disponibles

### Sensores Numéricos

| Sensor | Columna | Unidad | Descripción |
|--------|---------|--------|-------------|
| `temperatura` | tempC | °C | Temperatura en grados Celsius |
| `humedad` | hum% | % | Humedad relativa |
| `co2` | co2_ppm | ppm | Concentración de CO2 |
| `luz_raw` | ldr_raw | - | Valor raw del sensor de luz |
| `luz_voltaje` | ldr_v | V | Voltaje del sensor de luz |
| `luz_porcentaje` | ldr_pct | % | Porcentaje de luz |
| `mq135_raw` | mq135_raw | - | Valor raw del sensor MQ135 |
| `rs_r0` | rs_r0 | - | Relación RS/R0 del sensor |

### Sensores Categóricos

| Sensor | Columna | Unidad | Descripción |
|--------|---------|--------|-------------|
| `calidad_aire` | quality | - | Calidad del aire |
| `luz_estado` | light | - | Estado de la luz (Oscuro/Claro) |

## 📊 Estructura de Respuesta

### Respuesta con Sensor Específico
```json
{
  "total_registros": 150,
  "filtros_aplicados": {
    "sensor": "temperatura",
    "device_id": "esp32-1",
    "start_date": "2025-09-18",
    "end_date": "2025-09-19"
  },
  "datos": [
    {
      "timestamp": "2025-09-18T00:44:51-06:00",
      "deviceId": "esp32-1",
      "valor": 20.2,
      "unidad": "°C",
      "sensor": "temperatura",
      "tipo": "numeric"
    }
  ]
}
```

### Respuesta con Todos los Datos
```json
{
  "total_registros": 150,
  "filtros_aplicados": {
    "sensor": null,
    "device_id": "esp32-1",
    "start_date": "2025-09-18",
    "end_date": "2025-09-19"
  },
  "datos": [
    {
      "timestamp": "2025-09-18T00:44:51-06:00",
      "deviceId": "esp32-1",
      "tempC": 20.2,
      "hum%": 74,
      "mq135_raw": 1503,
      "rs_r0": 2.269,
      "co2_ppm": 12,
      "quality": "Muy buena",
      "ldr_raw": 218,
      "ldr_v": 0.176,
      "ldr_pct": 0,
      "light": "Oscuro"
    }
  ]
}
```

## 🔍 Códigos de Estado HTTP

| Código | Descripción |
|--------|-------------|
| `200` | Éxito - Datos obtenidos correctamente |
| `400` | Error de solicitud - Formato de fecha inválido |
| `404` | No encontrado - Sensor no existe |
| `500` | Error interno del servidor |

## 📅 Formatos de Fecha Soportados

- **Solo fecha**: `YYYY-MM-DD` (ej: `2025-09-18`)
- **Fecha y hora ISO**: `YYYY-MM-DDTHH:MM:SS` (ej: `2025-09-18T00:44:51`)

## 🚀 Iniciar el Servidor

```bash
python3 flask_server_v2.py
```

El servidor estará disponible en: `http://localhost:5000`

## 📝 Notas Importantes

- Todos los parámetros de query son opcionales
- Si no se especifica `sensor`, se retornan todos los datos de todos los sensores
- Las fechas se pueden especificar con o sin hora
- Los valores nulos en los datos se omiten automáticamente
- Los números usan punto decimal (se convierten automáticamente desde coma decimal)
- El archivo CSV se carga en memoria al iniciar el servidor

## 🔄 Diferencias con la Versión Anterior

- **Estructura real**: Basado en el análisis del archivo CSV real
- **Más sensores**: 10 sensores diferentes (8 numéricos, 2 categóricos)
- **Filtro por dispositivo**: Nuevo filtro `device_id`
- **Formato de fecha ISO**: Soporte para timestamps ISO 8601
- **Tipos de datos**: Distinción entre sensores numéricos y categóricos
- **Archivo local**: Usa archivo CSV local en lugar de Google Sheets
