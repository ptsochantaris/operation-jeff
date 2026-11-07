# Q - snowfield split by rock cliffs.
#
# The art can't say which side of a cliff is up, so those are judgement calls,
# made from the art: each brown band shows its layered face, which is only
# visible from below, and the snow cornices hang over its top edge. So:
#   top-left plateau above the left band ......... high
#   right plateau beyond the right band .......... highest
#   central snowfield between them ............... middle
#   bottom-left, below the left band ............. low
#   the gully at the bottom (snow + debris) ...... floor
# Snow away from the rock is pinned to its region's level; the rock, the strip
# of snow along it and the open snow slope below the right band are left free,
# and filled with the smoothest surface that meets the pinned levels (Laplace).
import numpy as np
from scipy import ndimage, sparse
from scipy.sparse.linalg import spsolve
from PIL import ImageDraw
from hmlib import *
from regions_q import segment

LEVELS = {             # (x, y) inside the region -> lift in px
    (40, 50): 26,      # top-left plateau
    (312, 40): 31,     # right plateau (max lift; 28 read as too low on hardware)
    (200, 100): 16,    # centre
    (60, 235): 8,      # bottom-left
}
SLOPE = [(286, 190), (320, 190), (320, 256), (292, 256)]  # right plateau -> centre, snow
GULLY = [(172, 165), (178, 200), (180, 230), (180, 256)]   # floor, level GULLY_Z
GULLY_Z = 2
PIN_CLEARANCE = 1      # px of snow next to rock left free
CLIFF_SOFTEN = 1.0     # px blur on the cliff steps - just takes the stair edge off

def laplace_fill(z, known):
    H, W = z.shape
    idx = -np.ones((H, W), int)
    unk = np.argwhere(~known)
    idx[~known] = np.arange(len(unk))
    rows, cols, vals = [], [], []
    b = np.zeros(len(unk))
    for k, (y, x) in enumerate(unk):
        nb = [(y + dy, x + dx) for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1))
              if 0 <= y + dy < H and 0 <= x + dx < W]
        rows.append(k); cols.append(k); vals.append(len(nb))
        for ny, nx in nb:
            if known[ny, nx]:
                b[k] += z[ny, nx]
            else:
                rows.append(k); cols.append(idx[ny, nx]); vals.append(-1)
    A = sparse.csr_matrix((vals, (rows, cols)), shape=(len(unk), len(unk)))
    out = z.copy()
    out[~known] = spsolve(A, b)
    return out

def screen_heights():
    rock, _, _ = segment()
    # morphology nibbles the bands where they meet the image edge; the frame
    # hides those rows anyway, so carry the first real row/column out over it
    t = FRAME + 4
    rock[:t] = rock[t]; rock[:, :t] = rock[:, t:t + 1]
    rock[-3:] = rock[-4]; rock[:, -3:] = rock[:, -4:-3]
    free = Image.fromarray((rock * 255).astype(np.uint8))
    d = ImageDraw.Draw(free)
    # the right band peters out into a plain snow slope down to the bottom edge
    d.polygon(SLOPE, fill=255)
    free = np.asarray(free) > 0
    sl = Image.new("L", (320, 256)); ImageDraw.Draw(sl).polygon(SLOPE, fill=255)
    slope = np.asarray(sl) > 0
    g = Image.new("L", (320, 256)); ImageDraw.Draw(g).line(GULLY, fill=255, width=8)
    gully = np.asarray(g) > 0
    # cut the snow into regions along the rock, the slope and the gully floor
    lab, n = ndimage.label(~(free | gully))
    z = np.zeros(rock.shape)
    pinned = np.zeros(rock.shape, bool)
    clear = ndimage.distance_transform_edt(~(free | gully)) > PIN_CLEARANCE
    for (x, y), level in LEVELS.items():
        region = lab == lab[y, x]
        assert lab[y, x] > 0, (x, y)
        z[region & clear] = level
        pinned |= region & clear
    z[gully] = GULLY_Z; pinned |= gully
    # Cliffs are steps, not ramps: every rock pixel takes the level of the
    # nearest pinned snow, so each band drops along its middle. (A Laplace fill
    # here made every cliff a ramp the full width of its band, and jeffs
    # "hovered" up them - Paul, on hardware.)
    _, (iy, ix) = ndimage.distance_transform_edt(~pinned, return_indices=True)
    z = z[iy, ix]
    # ...except the open snow slope below the right band, which stays a ramp
    z = laplace_fill(z, ~slope)
    return ndimage.gaussian_filter(z, CLIFF_SOFTEN), lab, free

def generate():
    z, lab, free = screen_heights()
    return quantise(to_cells(to_ground(z))), lab, free
