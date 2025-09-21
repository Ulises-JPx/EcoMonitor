"""
__init__.py
------------
Route package initializer.
Registers all blueprints with the Flask app.
"""

from .root import root_bp
from .data import data_bp
from .sensors import sensors_bp
from .devices import devices_bp


def register_routes(app):
    """
    Register all route blueprints with the Flask application.
    """
    # Root (GET /)
    app.register_blueprint(root_bp)

    # Data endpoint (GET /data)
    app.register_blueprint(data_bp)

    # Sensors endpoint (GET /sensors)
    app.register_blueprint(sensors_bp)

    # Devices endpoint (GET /devices)
    app.register_blueprint(devices_bp)