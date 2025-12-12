from flask import Blueprint, jsonify, request

# Minimal, correct blueprint object name required by app/__init__.py
auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/ping', methods=['GET'])
def ping():
    return jsonify({"status": "ok", "component": "auth"})

# Minimal placeholder endpoints
@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json() or {}
    username = data.get('username')
    if not username:
        return jsonify({"error": "username required"}), 400
    return jsonify({"msg": f"user {username} registered (placeholder)"}), 201

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json() or {}
    username = data.get('username')
    if not username:
        return jsonify({"error": "username required"}), 400
    return jsonify({"access_token": f"demo-token-for-{username}"}), 200
