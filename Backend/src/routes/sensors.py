from flask import Blueprint, jsonify
from config.settings import SENSORS

sensors_bp = Blueprint("sensors", __name__)

@sensors_bp.route("/sensors", methods=["GET"])
def get_sensors():
    return jsonify({
        "sensors": SENSORS,
        "total": len(SENSORS),
        "numeric": [name for name, cfg in SENSORS.items() if cfg["type"] == "numeric"],
        "categorical": [name for name, cfg in SENSORS.items() if cfg["type"] == "categorical"]
    })