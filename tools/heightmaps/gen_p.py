# P - posterised colour blobs, each lighter in the middle than at its rim.
# Plain brightness would mostly rank the colours (yellow over blue), so use
# local contrast instead: a blob's centre standing out from its surroundings
# is a hill, its darker rings the slopes. The surface is painted, so it gets
# the usual screen->ground correction.
import numpy as np
from scipy import ndimage
from hmlib import *

BASE, HILL = 2, 10      # level of the surroundings, extra lift at the brightest centres
SCALE = 22              # px - roughly a blob's radius


def screen_heights():
    _, a = load_art("P")
    l = luminance(a)
    c = ndimage.gaussian_filter(l, 5) - ndimage.gaussian_filter(l, SCALE)
    lo, hi = np.percentile(c[20:, 20:], [5, 98])
    t = np.clip((c - lo) / (hi - lo), 0, 1)
    return BASE + HILL * ndimage.gaussian_filter(t, 2.5)


def generate():
    return quantise(to_cells(to_ground(screen_heights())))
