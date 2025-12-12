from flask import Blueprint, jsonify
steg_bp = Blueprint('steg', __name__)

@steg_bp.route('/ping', methods=['GET'])
def ping():
    return jsonify({"status": "ok", "component": "steg"})
