from .extensions import db
from datetime import datetime
from sqlalchemy.dialects.postgresql import BYTEA, TEXT

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)  # store bcrypt hash
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class KeyPair(db.Model):
    __tablename__ = 'keypairs'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    public_key_pem = db.Column(TEXT, nullable=False)
    private_key_encrypted = db.Column(BYTEA, nullable=False)  # encrypted with user's password-derived key
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
