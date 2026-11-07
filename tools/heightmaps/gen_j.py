# J - cracked soil: segment the cracks, raise the plates between them.
#
# Plates are flat-topped at PLATE px, rolling down into the cracks over ROLL px.
# Height follows the signed distance to a crack edge, so a hairline crack only
# dips a little while the wide fissure bottoms out at 0.
import numpy as np
from scipy import ndimage
from hmlib import *

PLATE = 14
ROLL = 5.0     # px from crack edge to full plate height
DOME = 3.0     # extra px at the middle of a big plate
CRACK = 2.0    # px into a crack before it reaches the bottom

def screen_heights():
    _, a = load_art("J")
    l = luminance(a)
    ls = ndimage.gaussian_filter(l, 0.7)
    # dark outright, or clearly darker than the clay around it (faint hairlines)
    crack = (ls < 30) | (ls < 0.6 * ndimage.gaussian_filter(l, 6))
    crack = ndimage.binary_closing(crack, structure=np.ones((3, 3)))  # rejoin broken hairlines
    # drop specks (pores in the clay), keeping every crack however thin
    labels, n = ndimage.label(crack, structure=np.ones((3, 3)))
    sizes = ndimage.sum(crack, labels, range(1, n + 1))
    crack = np.isin(labels, 1 + np.flatnonzero(sizes >= 25))
    outside = ndimage.distance_transform_edt(~crack)
    inside = ndimage.distance_transform_edt(crack)
    sd = outside - inside
    h = PLATE * np.clip((sd + CRACK) / (ROLL + CRACK), 0, 1)
    h = PLATE * (3 * (h / PLATE) ** 2 - 2 * (h / PLATE) ** 3)  # smoothstep the roll
    h += DOME * np.clip((outside - ROLL) / 20.0, 0, 1)  # plates rise a little to their middles
    return ndimage.gaussian_filter(h, 1.0), crack

def generate():
    h, crack = screen_heights()
    return quantise(to_cells(to_ground(h))), crack
