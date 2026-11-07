from hmlib import *
from PIL import ImageDraw

def segment():
    _, a = load_art('Q')
    s = np.stack([ndimage.gaussian_filter(a[..., i], 1.0) for i in range(3)], -1)
    lum = luminance(s)
    rock = ((s[..., 0] - s[..., 2]) > 10) | (lum < 125)
    rock = ndimage.binary_closing(rock, np.ones((5, 5)))
    rock = ndimage.binary_opening(rock, np.ones((3, 3)))
    lab, n = ndimage.label(~rock)
    return rock, lab, n
