"""
app.py
-------
Flask application entry point.
"""

from flask import Flask
from flask_cors import CORS
from routes import register_routes
from config.settings import FLASK_HOST, FLASK_PORT, DEBUG_MODE

# Initialize Flask app
app = Flask(__name__)
# Enable CORS for all routes (allow frontend to call API from browser)
CORS(app)

# Register all routes
register_routes(app)

if __name__ == "__main__":
    print("Starting ECOMONITOR Flask API...")
    print(f"Available at: http://{FLASK_HOST}:{FLASK_PORT}")
    print("\n📋 Endpoints:")
    print("  GET /           - API documentation")
    print("  GET /data       - Sensor data with filters")
    print("  GET /sensors    - List available sensors")
    print("  GET /devices    - List available devices\n")

    # Run server
    app.run(debug=DEBUG_MODE, host=FLASK_HOST, port=FLASK_PORT)