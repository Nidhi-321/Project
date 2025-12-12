# adaptive LSB embedding for PNG/JPEG using PIL + numpy
from PIL import Image
import numpy as np
import math
from io import BytesIO

def image_complexity(img_array: np.ndarray) -> float:
    # compute per-channel variance as complexity measure
    return float(np.var(img_array))

def select_lsb_depth(img_array: np.ndarray, target_payload_bytes: int) -> int:
    # simple heuristic: higher variance -> allow deeper embedding
    var = image_complexity(img_array)
    # normalize: variance typically 0-65025 for uint8; map to depth 1-3
    if var < 200:
        return 1
    elif var < 2000:
        return 2
    else:
        return 3

def embed_lsb(image_bytes: bytes, payload: bytes, max_depth_override: int = None) -> bytes:
    img = Image.open(BytesIO(image_bytes)).convert('RGB')
    arr = np.array(img)
    h, w, c = arr.shape
    total_bits = h * w * c * 1  # base for depth=1
    # determine depth
    depth = select_lsb_depth(arr, len(payload))
    if max_depth_override:
        depth = min(depth, max_depth_override)
    capacity_bits = h * w * c * depth
    if len(payload) * 8 + 32 > capacity_bits:
        raise ValueError("Payload too large for this image (capacity {}).".format(capacity_bits))
    # prepare bit stream (prefix length)
    payload_len = len(payload)
    length_prefix = payload_len.to_bytes(4, 'big')
    bitstream = ''.join(f'{b:08b}' for b in length_prefix + payload)
    bit_iter = iter(bitstream)
    # embed
    flat = arr.reshape(-1)
    for i in range(len(flat)):
        for d in range(depth):
            try:
                bit = next(bit_iter)
            except StopIteration:
                break
            flat[i] = (flat[i] & ~(1 << d)) | (int(bit) << d)
        if len(bitstream) <= (i+1)*depth:
            break
    new_arr = flat.reshape(arr.shape)
    out = Image.fromarray(new_arr.astype('uint8'), 'RGB')
    buf = BytesIO()
    out.save(buf, format='PNG', optimize=True)
    return buf.getvalue()

def extract_lsb(image_bytes: bytes) -> bytes:
    img = Image.open(BytesIO(image_bytes)).convert('RGB')
    arr = np.array(img)
    h, w, c = arr.shape
    # We don't know depth used; try up to 3
    for depth in (1,2,3):
        flat = arr.reshape(-1)
        bits = []
        for val in flat:
            for d in range(depth):
                bits.append(str((val >> d) & 1))
        # reconstruct first 32 bits for length
        bstr = ''.join(bits)
        try:
            length = int(bstr[:32], 2)
        except:
            continue
        total_bits_needed = 32 + length*8
        if total_bits_needed > len(bstr):
            continue
        payload_bits = bstr[32:32+length*8]
        payload_bytes = bytes(int(payload_bits[i:i+8], 2) for i in range(0, len(payload_bits), 8))
        return payload_bytes
    raise ValueError("No embedded payload found")
