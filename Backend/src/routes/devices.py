from flask import Blueprint, jsonify
from services.data_service import load_sheet_data

devices_bp = Blueprint("devices", __name__)

@devices_bp.route("/devices", methods=["GET"])
def get_devices():
    try:
        all_data = load_sheet_data()
        devices = list(set(item["deviceId"] for item in all_data if "deviceId" in item))
        return jsonify({
            "devices": devices,
            "total": len(devices)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500