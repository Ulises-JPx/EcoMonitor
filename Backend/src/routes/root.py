from flask import Blueprint, jsonify
from config.settings import SENSORS

root_bp = Blueprint("root", __name__)

@root_bp.route("/", methods=["GET"])
def root():
    return jsonify({
        "message": "ECOMONITOR API 🌱",
        "endpoints": {
            "/data": "Get sensor data with filters",
            "/sensors": "List available sensors",
            "/devices": "List available devices"
        },
        "filters": {
            "sensor": f"One of: {', '.join(SENSORS.keys())}",
            "device_id": "Device identifier (e.g., esp32-1)",
            "start_date": "YYYY-MM-DD or ISO format",
            "end_date": "YYYY-MM-DD or ISO format"
        }
    })