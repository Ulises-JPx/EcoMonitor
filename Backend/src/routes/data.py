from flask import Blueprint, request, jsonify
from services.data_service import get_data_with_filters

data_bp = Blueprint("data", __name__)

@data_bp.route("/data", methods=["GET"])
def get_data():
    try:
        sensor = request.args.get("sensor")
        device_id = request.args.get("device_id")
        start_date = request.args.get("start_date")
        end_date = request.args.get("end_date")

        data, error = get_data_with_filters(sensor, start_date, end_date, device_id)

        if error:
            return jsonify({"error": error}), 404

        return jsonify({
            "records": len(data),
            "filters": {
                "sensor": sensor,
                "device_id": device_id,
                "start_date": start_date,
                "end_date": end_date
            },
            "data": data
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500
