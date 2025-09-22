# EcoMonitor — Backend API

Professional, lightweight Flask-based API that provides sensor data ingestion and query endpoints for the EcoMonitor project.

This README documents how to install, configure, run, test and deploy the backend service. It also includes examples for common API calls and troubleshooting notes.

## Contents

- Overview
- Requirements
- Quick start (local)
- Configuration
- Endpoints & examples
- Testing
- Deployment (Docker)
- Troubleshooting
- Contributing
- License

## Overview

The Backend is a Flask application that exposes a small REST API to access sensor measurements collected from Google Sheets or a local CSV fallback. It offers filtering by sensor, device and time range. The project is intentionally lightweight to make it easy to run locally or inside containers.

Key features

- Load sensor data from public Google Sheets URLs (configurable) or local CSV file
- Filter data by sensor name, device id and ISO/DATE ranges
- Expose endpoints: `/`, `/data`, `/sensors`, `/devices`
- Simple, dependency-light Python stack

## Requirements

- Python 3.9+ (3.10/3.11 recommended)
- pip
- Git (optional)

Python dependencies are declared in `requirements.txt`:

- flask
- flask-cors
- requests
- pandas
- openpyxl
- google-api-python-client
- google-auth-httplib2
- google-auth-oauthlib
- gspread (optional)
- pygsheets (optional)

Install dependencies into a virtualenv for a clean environment:

```bash
# macOS / Linux (zsh)
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r Backend/requirements.txt
```

## Quick start (local)

1. Ensure dependencies are installed (see Requirements).
2. Start the API server:

```bash
cd Backend
source ../.venv/bin/activate  # if you created a virtualenv in repo root
python src/app.py
```

By default the app prints the listening address and reveals available endpoints. Default host/port are configured in `src/config/settings.py` (FLASK_HOST, FLASK_PORT).

If you prefer to run with environment isolation use Docker (see Deployment).

## Configuration

All runtime configuration is in `src/config/settings.py`.

Important values:

- SHEET_URLS: list of public Google Sheets CSV export URLs (preferred source)
- CSV_FILE: local CSV fallback path
- FLASK_HOST, FLASK_PORT, DEBUG_MODE: Flask server options
- SENSORS: mapping of sensor logical names to CSV columns, units and types

You can override configuration by editing `settings.py` or by creating a simple wrapper script that sets environment variables and updates app config before calling `app.run(...)`.

## API Endpoints

Base URL: http://<host>:<port>/ (default: 0.0.0.0:5001)

1) GET /

Returns a small JSON with API information and available endpoints.

Example response:

```json
{
  "message": "ECOMONITOR API 🌱",
  "endpoints": { "/data": "Get sensor data with filters", "/sensors": "List available sensors", "/devices": "List available devices" }
}
```

2) GET /data

Query parameters:
- sensor (optional) — logical sensor key (see `SENSORS` in settings)
- device_id (optional)
- start_date (optional) — YYYY-MM-DD or full ISO (e.g. 2024-01-02T15:04:05)
- end_date (optional)

Behavior:

- If `sensor` is provided: returns an array of objects with timestamp, deviceId, value, unit, sensor and type
- Without `sensor` it returns the raw dataset rows filtered by device and date range

Examples:

Request: GET /data?sensor=temperature&device_id=esp32-1&start_date=2024-01-01

Response (abbreviated):

```json
{
  "records": 123,
  "filters": {"sensor":"temperature","device_id":"esp32-1","start_date":"2024-01-01","end_date":null},
  "data": [ {"timestamp":"2024-01-02T12:00:00Z","deviceId":"esp32-1","value":23.4,"unit":"°C","sensor":"temperature","type":"numeric"}, ... ]
}
```

3) GET /sensors

Returns the sensor mapping defined in configuration with lists of numeric and categorical sensors.

4) GET /devices

Returns a list of device identifiers discovered in the dataset.

## Error handling & status codes

- 200: successful request
- 404: not found or invalid sensor name
- 500: internal server error or data loading failure

When date formats are invalid, the API returns a 404 with a helpful message (see `data_service.get_data_with_filters`).

## Testing

There is a simple test file at `test/test_api.py`. To run the tests:

```bash
# From the repository root
source .venv/bin/activate
pip install -r Backend/requirements.txt pytest
pytest -q
```

If you add tests, keep them small and focused. Consider mocking `requests.get` when testing Google Sheets download behavior.

## Deployment (Docker)

Below is a small Dockerfile you can use in the Backend folder. Create `Backend/Dockerfile` with:

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY Backend/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY Backend/src ./src
ENV PYTHONUNBUFFERED=1
EXPOSE 5001
CMD ["python", "src/app.py"]
```

Build and run:

```bash
docker build -t ecomonitor-backend .
docker run -p 5001:5001 --rm ecomonitor-backend
```

Tip: mount a volume for a local CSV fallback if you want to provide custom data:

```bash
docker run -p 5001:5001 -v $(pwd)/Backend/data:/app/data ecomonitor-backend
```

## Troubleshooting

- If Google Sheets are not public, the service will fallback to the local CSV. Ensure `SHEET_URLS` point to an export CSV link or the sheet is public.
- Common error: network timeouts when fetching Sheets — increase requests timeout in `data_service.load_sheet_data` if needed.
- CSV paths are relative to the working directory; use absolute paths or mount volumes in Docker to avoid file-not-found errors.

## Contributing

Contributions are welcome. To contribute:

1. Fork the repository
2. Create a feature branch
3. Run tests and linters locally
4. Open a PR with a clear description

Keep changes small and provide unit tests for non-trivial logic.

## License

See the repository `LICENSE` for license details.

---
Generated and maintained by the EcoMonitor project maintainers.
