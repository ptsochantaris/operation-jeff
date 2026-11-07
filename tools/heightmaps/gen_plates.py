# Raised plates between channels - the J method, shared by L (turf tiles
# between dark grooves) and M (rock plates between lava). J keeps its own
# script (gen_j.py) since its map is approved as-is.
#
# Height follows the signed distance to a channel edge: full PLATE height ROLL
# px in from the edge, the channel bottoming out CRACK px in, plus DOME px of
# rise towards the middle of big plates.
import sys
import numpy as np
from scipy import ndimage
from hmlib import *


def clean(mask, close=1, min_size=25):
    if close:
        mask = ndimage.binary_closing(mask, structure=np.ones((3, 3)), iterations=close)
    labels, n = ndimage.label(mask, structure=np.ones((3, 3)))
    sizes = ndimage.sum(mask, labels, range(1, n + 1))
    return np.isin(labels, 1 + np.flatnonzero(sizes >= min_size))


def line_response(l, axis, across=9, along=21):
    """How much darker each pixel is than its surroundings across a line that
    runs along `axis`, averaged along the line so only long grooves survive."""
    across_mean = ndimage.uniform_filter1d(l, across, axis=1 - axis)
    r = across_mean - l
    return ndimage.uniform_filter1d(r, along, axis=axis)


def long_runs(mask, axis, min_len):
    """Keep only connected pieces of `mask` spanning >= min_len px along axis."""
    labels, n = ndimage.label(mask, structure=np.ones((3, 3)))
    keep = np.zeros(n + 1, bool)
    for i, sl in enumerate(ndimage.find_objects(labels), 1):
        if sl is not None and sl[axis].stop - sl[axis].start >= min_len:
            keep[i] = True
    return keep[labels]


def mask_L(a):
    # grooves between the turf tiles: long thin dark lines. Horizontal ones are
    # plain; vertical ones are faint, so they take a lower threshold and must
    # each run most of a tile row (rows are 30-50 px) to count
    l = ndimage.gaussian_filter(luminance(a), 0.7)
    vertical = long_runs(line_response(l, axis=0) > 5, axis=0, min_len=24)
    horizontal = long_runs(line_response(l, axis=1) > 9, axis=1, min_len=40)
    return clean(vertical | horizontal, close=1, min_size=60)


def mask_M(a):
    # lava: strongly red against the bluish rock
    s = np.stack([ndimage.gaussian_filter(a[..., i], 1.0) for i in range(3)], -1)
    return clean((s[..., 0] - s[..., 2]) > 40, close=1, min_size=40)


CONFIG = {
    #     mask     PLATE ROLL DOME CRACK
    "L": (mask_L,  12,   3.0, 2.0, 1.5),
    "M": (mask_M,  16,   5.0, 3.0, 3.0),
}

# The screen->ground correction slides each lifted surface down by its own
# height, so a groove thinner than the plate above it gets covered over. L's
# horizontal grooves (1-2 px under 12 px tiles) vanished that way, and on flat
# uniform tiles the correction buys nothing - so L goes without it.
NO_GROUND_WARP = {"L"}

# Per-level overrides of hmlib's calibration shifts, from hardware testing.
X_SHIFT = {}
Y_SHIFT = {}


def screen_heights(L):
    mask_fn, plate, roll, dome, crack = CONFIG[L]
    _, a = load_art(L)
    channel = mask_fn(a)
    outside = ndimage.distance_transform_edt(~channel)
    inside = ndimage.distance_transform_edt(channel)
    sd = outside - inside
    t = np.clip((sd + crack) / (roll + crack), 0, 1)
    h = plate * (3 * t ** 2 - 2 * t ** 3)
    h += dome * np.clip((outside - roll) / 20.0, 0, 1)
    return ndimage.gaussian_filter(h, 1.0), channel


def generate(L):
    h, channel = screen_heights(L)
    g = h if L in NO_GROUND_WARP else to_ground(h)
    return quantise(to_cells(g, x_shift=X_SHIFT.get(L), y_shift=Y_SHIFT.get(L))), channel
