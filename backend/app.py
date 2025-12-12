import os
import logging
from flask import Flask, request, jsonify, send_from_directory
from flask_socketio import SocketIO, emit, join_room
from models import db, User, Message
from sqlalchemy.exc import IntegrityError
from werkzeug.utils import secure_filename

# Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration (prefer env vars)
# Note: password contains '@' — use %40 when embedding in a URL.
DATABASE_URL = os.environ.get(
    "DATABASE_URL",
    "postgresql://postgres:Edith%40gamora@localhost:5432/stegcryptdb"
)
UPLOAD_FOLDER = os.environ.get("UPLOAD_FOLDER", os.path.join(os.path.dirname(__file__), "uploads"))
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "gif"}
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = DATABASE_URL
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

# Initialize DB
db.init_app(app)

# Flask 3.x compatible startup hook
with app.app_context():
    # db.create_all()  # uncomment only for dev; prefer alembic migrations for production
    pass

# SocketIO: use gevent on Windows to avoid Eventlet TIME_WAIT binding issues
socketio = SocketIO(app, cors_allowed_origins="*", async_mode="gevent", ping_timeout=60, ping_interval=25)

# In-memory connected clients map: user_id -> set(socket_sid)
connected_users = {}

# Helper: allowed extension
def allowed_file(filename):
    return "." in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Development helper: serve uploaded files. Use proper static hosting in production.
@app.route('/uploads/<path:filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename, as_attachment=False)

# User registration (safer, avoids IntegrityError from duplicate inserts)
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json(force=True)
    username = data.get('username')
    public_key_pem = data.get('public_key_pem')

    if not username:
        return jsonify({'error': 'username required'}), 400

    try:
        # Try to find existing user
        existing = User.query.filter_by(username=username).first()
        if existing:
            # Update fields if provided
            if public_key_pem:
                existing.public_key_pem = public_key_pem
            existing.last_seen = db.func.now()
            db.session.commit()
            # broadcast updated list so clients get keys automatically
            broadcast_users()
            return jsonify({'user': existing.to_dict()}), 200

        # No existing user -> create new
        user = User(username=username, public_key_pem=public_key_pem)
        db.session.add(user)
        db.session.commit()

        broadcast_users()
        return jsonify({'user': user.to_dict()}), 201

    except Exception as e:
        # Log full exception locally for debugging
        logger.exception("Register failed")
        # Return a helpful message in dev. In production omit detailed DB errors.
        return jsonify({'error': 'could not register', 'detail': str(e)}), 500

# List users
@app.route('/users', methods=['GET'])
def list_users():
    users = User.query.all()
    return jsonify({'users': [u.to_dict() for u in users]})

# Upload ciphertext or stego image
@app.route('/upload_ciphertext', methods=['POST'])
def upload_ciphertext():
    """
    Accepts either:
      - multipart form with 'file', 'sender_id', 'receiver_id' (file saved and path stored in ciphertext), or
      - JSON { sender_id, receiver_id, ciphertext }
    """
    j = None
    try:
        j = request.get_json(force=False, silent=True)
    except Exception:
        j = None

    if 'file' in request.files:
        f = request.files['file']
        if f and allowed_file(f.filename):
            filename = secure_filename(f.filename)
            path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            f.save(path)
            ciphertext = path
        else:
            return jsonify({'error': 'file missing or invalid extension'}), 400
    else:
        if j and 'ciphertext' in j:
            ciphertext = j.get('ciphertext')
        else:
            ciphertext = request.form.get('ciphertext')

    sender_id = request.form.get('sender_id') or (j.get('sender_id') if j else None)
    receiver_id = request.form.get('receiver_id') or (j.get('receiver_id') if j else None)

    if not sender_id or not receiver_id or not ciphertext:
        return jsonify({'error': 'missing fields'}), 400

    msg = Message(sender_id=int(sender_id), receiver_id=int(receiver_id), ciphertext=ciphertext)
    db.session.add(msg)
    db.session.commit()

    emit_message_to_recipient(msg.to_dict())
    return jsonify({'message': msg.to_dict()}), 201

# Socket helpers
def emit_message_to_recipient(msg_dict):
    rid = msg_dict['receiver_id']
    sids = connected_users.get(rid, set())
    if sids:
        for sid in list(sids):
            socketio.emit('new_message', msg_dict, room=sid)

def broadcast_users():
    users = [u.to_dict() for u in User.query.all()]
    socketio.emit('users_list', {'users': users})

# Socket handlers
@socketio.on('connect')
def on_connect():
    logger.info(f'socket connected: {request.sid}')

@socketio.on('identify')
def on_identify(data):
    user_id = data.get('user_id')
    if not user_id:
        return
    user_id = int(user_id)
    s = connected_users.setdefault(user_id, set())
    s.add(request.sid)
    join_room(request.sid)
    u = User.query.get(user_id)
    if u:
        u.last_seen = db.func.now()
        db.session.commit()
    broadcast_users()
    logger.info(f'user {user_id} identified on sid {request.sid}')

@socketio.on('disconnect')
def on_disconnect():
    sid = request.sid
    to_remove = []
    for uid, sids in list(connected_users.items()):
        if sid in sids:
            sids.remove(sid)
            if not sids:
                to_remove.append(uid)
    for uid in to_remove:
        connected_users.pop(uid, None)
    broadcast_users()
    logger.info(f'sid disconnected: {sid}')

@socketio.on('client_send')
def on_client_send(data):
    sender_id = int(data.get('sender_id'))
    receiver_id = int(data.get('receiver_id'))
    ciphertext = data.get('ciphertext')
    if not sender_id or not receiver_id or not ciphertext:
        emit('error', {'error': 'missing fields'})
        return

    msg = Message(sender_id=sender_id, receiver_id=receiver_id, ciphertext=ciphertext)
    db.session.add(msg)
    db.session.commit()
    emit_message_to_recipient(msg.to_dict())
    emit('sent_ack', msg.to_dict())

if __name__ == '__main__':
    # Development run; in production use gunicorn + gevent
    host = os.environ.get('HOST', '127.0.0.1')
    port = int(os.environ.get('PORT', 5001))
    socketio.run(app, host=host, port=port)
