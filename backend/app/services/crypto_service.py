# responsible for RSA key generation, encryption/decryption, AES-GCM symmetric encryption
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.kdf.scrypt import Scrypt
import os

def generate_rsa_keypair(bits=2048):
    private_key = rsa.generate_private_key(public_exponent=65537, key_size=bits)
    priv_pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )
    pub_pem = private_key.public_key().public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )
    return priv_pem, pub_pem

def rsa_encrypt(public_pem: bytes, plaintext: bytes) -> bytes:
    pub = serialization.load_pem_public_key(public_pem)
    ct = pub.encrypt(plaintext,
                     padding.OAEP(mgf=padding.MGF1(algorithm=hashes.SHA256()),
                                  algorithm=hashes.SHA256(), label=None))
    return ct

def rsa_decrypt(private_pem: bytes, ciphertext: bytes) -> bytes:
    priv = serialization.load_pem_private_key(private_pem, password=None)
    pt = priv.decrypt(ciphertext,
                      padding.OAEP(mgf=padding.MGF1(algorithm=hashes.SHA256()),
                                   algorithm=hashes.SHA256(), label=None))
    return pt

def aesgcm_encrypt(key: bytes, plaintext: bytes, aad: bytes=b'') -> dict:
    # key must be 16/24/32 bytes
    aes = AESGCM(key)
    nonce = os.urandom(12)
    ct = aes.encrypt(nonce, plaintext, aad)
    return {'nonce': nonce, 'ciphertext': ct}

def aesgcm_decrypt(key: bytes, nonce: bytes, ciphertext: bytes, aad: bytes=b'') -> bytes:
    aes = AESGCM(key)
    return aes.decrypt(nonce, ciphertext, aad)

def derive_key_from_password(password: bytes, salt: bytes = None) -> (bytes, bytes):
    if salt is None:
        salt = os.urandom(16)
    kdf = Scrypt(salt=salt, length=32, n=2**14, r=8, p=1)
    key = kdf.derive(password)
    return key, salt
