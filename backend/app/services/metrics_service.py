import numpy as np
from PIL import Image
from skimage.metrics import structural_similarity as ssim
import math
from io import BytesIO

def psnr(original_bytes: bytes, modified_bytes: bytes) -> float:
    ori = np.array(Image.open(BytesIO(original_bytes)).convert('RGB')).astype(np.float64)
    mod = np.array(Image.open(BytesIO(modified_bytes)).convert('RGB')).astype(np.float64)
    mse = ((ori - mod) ** 2).mean()
    if mse == 0:
        return float('inf')
    PIXEL_MAX = 255.0
    return 20 * math.log10(PIXEL_MAX / math.sqrt(mse))

def compute_ssim(original_bytes: bytes, modified_bytes: bytes) -> float:
    ori = np.array(Image.open(BytesIO(original_bytes)).convert('L'))
    mod = np.array(Image.open(BytesIO(modified_bytes)).convert('L'))
    return float(ssim(ori, mod))

def mse(original_bytes: bytes, modified_bytes: bytes) -> float:
    ori = np.array(Image.open(BytesIO(original_bytes)).convert('RGB')).astype(np.float64)
    mod = np.array(Image.open(BytesIO(modified_bytes)).convert('RGB')).astype(np.float64)
    return float(((ori - mod) ** 2).mean())
