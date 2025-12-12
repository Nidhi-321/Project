import pytest
from app.services.stego_service import embed_lsb, extract_lsb
from PIL import Image
from io import BytesIO

def create_test_image():
    img = Image.new('RGB', (200,200), color=(120,130,140))
    buf = BytesIO()
    img.save(buf, format='PNG')
    return buf.getvalue()

def test_embed_extract_roundtrip():
    img_bytes = create_test_image()
    payload = b'hello stegcrypt'
    stego = embed_lsb(img_bytes, payload)
    extracted = extract_lsb(stego)
    assert extracted == payload
