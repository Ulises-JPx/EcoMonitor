"""
data_service.py
----------------
Business logic for loading, cleaning, and filtering sensor data.
"""

import requests
import csv
import io
from datetime import datetime
from config.settings import SHEET_URLS, CSV_FILE, SENSORS


def load_sheet_data():
    """
    Loads data from Google Sheets (preferred) or CSV fallback.
    Returns a list of dictionaries (rows).
    """
    # Try each Google Sheet URL
    for i, sheet_url in enumerate(SHEET_URLS):
        try:
            response = requests.get(sheet_url, timeout=10)
            response.raise_for_status()

            # If Google returns an HTML error page
            if response.text.strip().startswith("<HTML>"):
                raise Exception("Google Sheet not publicly accessible")

            csv_data = csv.reader(io.StringIO(response.text))
            rows = list(csv_data)
            if not rows:
                raise Exception("Google Sheet is empty")

            return _process_csv_data(rows)
        except Exception:
            continue

    # Fallback → local CSV file
    try:
        with open(CSV_FILE, "r", encoding="utf-8") as file:
            csv_reader = csv.reader(file)
            rows = list(csv_reader)

        if not rows:
            raise Exception("Local CSV is empty")

        return _process_csv_data(rows)
    except Exception as e:
        print(f"[ERROR] Failed to load CSV: {e}")
        return []


def _process_csv_data(rows):
    """
    Convert CSV rows into a list of dictionaries.
    Cleans numeric values and preserves timestamps.
    """
    headers = rows[0]
    data = []

    for row in rows[1:]:
        if len(row) >= len(headers):  # Ignore incomplete rows
            row_dict = {}
            for i, header in enumerate(headers):
                value = row[i] if i < len(row) else ""
                row_dict[header] = value

            processed_row = {}
            for key, value in row_dict.items():
                if key == "timestamp":
                    processed_row[key] = value
                elif key == "deviceId":
                    processed_row[key] = value
                elif key in ["quality", "light"]:
                    processed_row[key] = value
                else:
                    try:
                        processed_row[key] = float(value.replace(",", ".")) if value else None
                    except (ValueError, AttributeError):
                        processed_row[key] = value
            data.append(processed_row)

    return data


def _parse_iso_date(date_str):
    """Convert ISO string to datetime object."""
    try:
        return datetime.fromisoformat(date_str.replace("Z", "+00:00"))
    except Exception:
        return None


def _filter_by_date(data, start_date=None, end_date=None):
    """Filter dataset by date range."""
    if not data:
        return []

    filtered = []
    for item in data:
        item_date = _parse_iso_date(item.get("timestamp"))
        if not item_date:
            continue

        if start_date and item_date < start_date:
            continue
        if end_date and item_date > end_date:
            continue

        filtered.append(item)

    return filtered


def get_data_with_filters(sensor=None, device_id=None, start_date_str=None, end_date_str=None):
    """
    Apply filters to the dataset.
    Returns (filtered_data, error_message).
    """
    try:
        # Load full dataset
        all_data = load_sheet_data()

        # Device filter
        if device_id:
            all_data = [item for item in all_data if item.get("deviceId") == device_id]

        # Date filters
        start_date = None
        end_date = None

        if start_date_str:
            try:
                start_date = datetime.fromisoformat(start_date_str.replace("Z", "+00:00"))
            except Exception:
                try:
                    start_date = datetime.strptime(start_date_str, "%Y-%m-%d")
                except Exception:
                    return None, "Invalid start_date format. Use YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS"

        if end_date_str:
            try:
                end_date = datetime.fromisoformat(end_date_str.replace("Z", "+00:00"))
            except Exception:
                try:
                    end_date = datetime.strptime(end_date_str, "%Y-%m-%d")
                except Exception:
                    return None, "Invalid end_date format. Use YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS"

        filtered_data = _filter_by_date(all_data, start_date, end_date)

        # Sensor filter
        if sensor:
            if sensor not in SENSORS:
                return None, f"Sensor '{sensor}' not found"

            column = SENSORS[sensor]["column"]
            sensor_data = []

            for item in filtered_data:
                if column in item and item[column] is not None:
                    sensor_data.append({
                        "timestamp": item["timestamp"],
                        "deviceId": item["deviceId"],
                        "value": item[column],
                        "unit": SENSORS[sensor]["unit"],
                        "sensor": sensor,
                        "type": SENSORS[sensor]["type"]
                    })

            return sensor_data, None

        # Default → return full dataset
        return filtered_data, None

    except Exception as e:
        return None, str(e)