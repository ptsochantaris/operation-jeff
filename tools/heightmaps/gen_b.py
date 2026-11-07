# B - a grid bent over a hump. In the game's projection a jeff at ground
# (x, y) with lift z is drawn at y - z, so a straight horizontal grid line
# lifted by z(x) is drawn bowed upwards by exactly z(x). Trace the horizontal
# lines, take each one's bow above the straight line joining its ends (the
# edges are flat), and interpolate. These are ground-space lifts already.
import numpy as np
from scipy import ndimage, interpolate
from hmlib import *
from gen_plates import line_response

X0, X1 = 24, 312          # traced span (painted area, clear of the frame)


def trace_lines():
    _, a = load_art("B")
    l = ndimage.gaussian_filter(luminance(a), 1.0)
    r = line_response(l, axis=1, across=7, along=9)   # dark horizontal lines
    lines = []
    # seeds: line centres in the leftmost column
    col = r[:, X0]
    seeds = [y for y in range(20, 252) if col[y] > 6 and col[y] == col[max(0, y - 3):y + 4].max()]
    for y0 in seeds:
        ys = [float(y0)]
        y = y0
        ok = True
        for x in range(X0 + 1, X1):
            lo, hi = max(0, y - 2), min(255, y + 3)
            seg = r[lo:hi, x]
            y = lo + int(np.argmax(seg))
            if r[y, x] < 2:          # lost the line
                ok = False
                break
            ys.append(float(y))
        if ok:
            lines.append(np.array(ys))
    return lines


def bows(lines):
    xs = np.arange(X0, X1)
    out = []
    for ys in lines:
        ys = ndimage.uniform_filter1d(ys, 7)
        base = np.interp(xs, [xs[0], xs[-1]], [ys[:10].mean(), ys[-10:].mean()])
        out.append((xs, ys, base - ys))     # upward bow = lift
    return out


def ground_heights():
    """Lift per ground pixel: each traced line gives its bow profile at its
    flat (ground) row; between lines, interpolate down each column with PCHIP
    (smooth, no overshoot). Zero at the top and bottom edges."""
    rows, profiles = [0.0], [np.zeros(320)]
    for xs, ys, z in bows(trace_lines()):
        p = np.zeros(320)
        p[X0:X1] = np.clip(z, 0, None)
        p = ndimage.gaussian_filter1d(p, 3)
        rows.append((ys[:10].mean() + ys[-10:].mean()) / 2)
        profiles.append(p)
    rows.append(255.0); profiles.append(np.zeros(320))
    order = np.argsort(rows)
    rows = np.array(rows)[order]; P = np.array(profiles)[order]
    f = interpolate.PchipInterpolator(rows, P, axis=0)
    return np.clip(f(np.arange(256)), 0, 31)


def generate():
    # already in ground space - no to_ground warp
    return quantise(to_cells(ground_heights()))
