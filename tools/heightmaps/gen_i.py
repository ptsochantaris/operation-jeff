# I - vertical strands of gold beads on a dark ground: ridges along the
# strands, troughs in the gaps. Brightness blurred hard along the strands
# (vertical) and lightly across them gives a ridge profile that follows any
# drift. Vertical ridges are unchanged by the screen->ground correction, so
# it's skipped.
import numpy as np
from scipy import ndimage
from hmlib import *

BASE, RIDGE = 2, 12      # trough level, extra lift on the brightest strand


def screen_heights():
    _, a = load_art("I")
    l = luminance(a)
    s = ndimage.gaussian_filter(l, (18, 2.5))       # (along, across) the strands
    # the art is lit brighter in the middle - lighting, not relief - so keep
    # only the strand-vs-gap variation
    s = s - ndimage.gaussian_filter(l, 30)
    lo, hi = np.percentile(s[20:, 20:], [3, 97])
    t = np.clip((s - lo) / (hi - lo), 0, 1)
    return BASE + RIDGE * t


def generate():
    return quantise(to_cells(screen_heights()))
