"""
settings.py
------------
Centralized configuration and constants for the backend service.
"""

# Google Sheets URLs (optional)
SHEET_URLS = [
    "https://docs.google.com/spreadsheets/d/1-fddNDMF-WcOc4fhixGO6s-rhJ1II06YArzblGHAXtM/export?format=csv&gid=1670363824",
    "https://docs.google.com/spreadsheets/d/1-fddNDMF-WcOc4fhixGO6s-rhJ1II06YArzblGHAXtM/export?format=csv&gid=0",
    "https://docs.google.com/spreadsheets/d/1-fddNDMF-WcOc4fhixGO6s-rhJ1II06YArzblGHAXtM/export?format=csv"
]

# Local CSV file fallback
CSV_FILE = "backend/data/sensors_data.csv"

# Flask server settings
FLASK_HOST = "0.0.0.0"
FLASK_PORT = 5001
DEBUG_MODE = True

# Sensors configuration
SENSORS = {
    'temperature': {
        'column': 'tempC',
        'unit': '°C',
        'description': 'Temperature in Celsius',
        'type': 'numeric'
    },
    'humidity': {
        'column': 'hum%',
        'unit': '%',
        'description': 'Relative humidity',
        'type': 'numeric'
    },
    'co2': {
        'column': 'co2_ppm',
        'unit': 'ppm',
        'description': 'CO2 concentration',
        'type': 'numeric'
    },
    'air_quality': {
        'column': 'quality',
        'unit': '',
        'description': 'Air quality',
        'type': 'categorical'
    },
    'light_raw': {
        'column': 'ldr_raw',
        'unit': '',
        'description': 'Raw light sensor value',
        'type': 'numeric'
    },
    'light_voltage': {
        'column': 'ldr_v',
        'unit': 'V',
        'description': 'Light sensor voltage',
        'type': 'numeric'
    },
    'light_percentage': {
        'column': 'ldr_pct',
        'unit': '%',
        'description': 'Light percentage',
        'type': 'numeric'
    },
    'light_state': {
        'column': 'light',
        'unit': '',
        'description': 'Light state (Dark/Bright)',
        'type': 'categorical'
    },
    'mq135_raw': {
        'column': 'mq135_raw',
        'unit': '',
        'description': 'MQ135 raw value',
        'type': 'numeric'
    },
    'rs_r0': {
        'column': 'rs_r0',
        'unit': '',
        'description': 'Sensor RS/R0 ratio',
        'type': 'numeric'
    }
}