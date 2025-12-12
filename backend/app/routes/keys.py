from flask import Blueprint, jsonify
keys_bp = Blueprint('keys', __name__)

@keys_bp.route('/ping', methods=['GET'])
def ping():
    return jsonify({"status": "ok", "component": "keys"})
