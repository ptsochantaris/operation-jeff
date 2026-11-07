# Shared plumbing for generating Operation Jeff heightmaps from the level art.
#
# Game facts this relies on (src/jeffpos.asm, src/stats.c):
#  - heightmap is 80x64 cells of 4x4 px, value z = PNG red / 8 (0..31)
#  - it is looked up at the jeff's *ground* position (feet), and the jeff is
#    drawn z px higher. So a surface painted at screen row s with lift h
#    belongs at ground row s + h - see to_ground().
import os
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ORIG = os.path.join(REPO, "resources_original")     # level art in, heightmap PNGs out
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "previews")  # gitignored
FRAME = 16  # black border on the left and top of the art


def load_art(letter):
    im = Image.open(f"{ORIG}/OperationJeffLevel{letter}.png").convert("RGB")
    a = np.asarray(im).astype(float)
    # mirror the painted area into the frame so filters don't see the black,
    # starting a few px in where the art's own edge has darkened
    t, e = FRAME + 4, 4
    a[:t] = a[2 * t - 1:t - 1:-1]
    a[:, :t] = a[:, 2 * t - 1:t - 1:-1]
    a[-e:] = a[-e - 1:-2 * e - 1:-1]
    a[:, -e:] = a[:, -e - 1:-2 * e - 1:-1]
    return im, a


def luminance(a):
    return 0.3 * a[..., 0] + 0.59 * a[..., 1] + 0.11 * a[..., 2]


def to_ground(hs):
    """Screen-space lift (256x320, px) -> ground-space lift.

    Each screen row s with lift h maps to ground row s + h. Where several
    screen rows land on one ground row keep the largest lift (the face nearer
    the viewer); fill the ground rows nothing lands on by interpolation."""
    H, W = hs.shape
    g = np.full((H, W), np.nan)
    for x in range(W):
        col = hs[:, x]
        for s in range(H):
            y = int(round(s + col[s]))
            if 0 <= y < H and not (g[y, x] >= col[s]):
                g[y, x] = col[s]
        known = ~np.isnan(g[:, x])
        idx = np.arange(H)
        g[:, x] = np.interp(idx, idx[known], g[known, x])
    return g


# Empirical calibration, from hardware (2026-11-07): with the geometry modelled
# above (lookup cell ((x+6)>>2, (y+14)>>2), sprite drawn at raw pos.x, figure
# centre x+7.5, feet on row 14), jeffs dipped ~8 px left of and ~4 px above
# the grooves on level 7 (L) - straight grooves both ways and no ground warp,
# so it's the calibration level. These shifts (positive = right/down) put the
# dips under the jeffs to within ~1 px. Y then trimmed from +4 to +2: Paul
# saw the dips still 1-2 px below the visible grooves. The cause of the gap between the model
# and the hardware is still unknown. Earlier guesses (+4/-4 etc., judged on J
# and Q) were confounded by the screen->ground warp.
GROUND_X_SHIFT = 8
GROUND_Y_SHIFT = 2


def shift_edge(g, n, axis):
    """Move g by n px along axis (positive = right/down), filling from the edge."""
    if n == 0:
        return g
    g = np.moveaxis(g, axis, 0)
    if n > 0:
        g = np.concatenate([np.repeat(g[:1], n, axis=0), g[:-n]], axis=0)
    else:
        g = np.concatenate([g[-n:], np.repeat(g[-1:], -n, axis=0)], axis=0)
    return np.moveaxis(g, 0, axis)


def to_cells(g, x_shift=None, y_shift=None):
    g = shift_edge(g, GROUND_X_SHIFT if x_shift is None else x_shift, axis=1)
    g = shift_edge(g, GROUND_Y_SHIFT if y_shift is None else y_shift, axis=0)
    return g.reshape(64, 4, 80, 4).mean(axis=(1, 3))


def quantise(cells):
    return np.rint(cells).clip(0, 31).astype(int)


def write_heightmap(letter, cells, path=None):
    path = path or f"{ORIG}/OperationJeffHeightmap{letter}.png"
    Image.fromarray((cells * 8 + 4).astype(np.uint8), "L").save(path)  # +4: makeAssets truncates r/8
    return path


def preview(letter, cells, tag="", old=None):
    """Art | heightmap | art with a ground grid draped over it the way the game
    lifts jeffs (grid point at ground (x, y) drawn at (x, y - z))."""
    im, _ = load_art(letter)
    im = Image.open(f"{ORIG}/OperationJeffLevel{letter}.png").convert("RGB")

    def draped(c, colour):
        o = im.copy()
        d = ImageDraw.Draw(o)
        z = lambda gx, gy: c[min(gy // 4, 63), min(gx // 4, 79)]
        step = 8
        for gy in range(0, 256, step):
            pts = [(gx, gy - z(gx, gy)) for gx in range(0, 320, 2)]
            d.line(pts, fill=colour)
        for gx in range(0, 320, step * 2):
            pts = [(gx, gy - z(gx, gy)) for gy in range(0, 256, 2)]
            d.line(pts, fill=colour)
        return o

    panels = [im]
    if old is not None:
        panels.append(Image.fromarray((old * 8).astype(np.uint8)).resize((320, 256), Image.NEAREST).convert("RGB"))
        panels.append(draped(old, (255, 0, 255)))
    panels.append(Image.fromarray((cells * 8).astype(np.uint8)).resize((320, 256), Image.NEAREST).convert("RGB"))
    panels.append(draped(cells, (0, 255, 255)))
    cols = 3 if old is None else 5
    if old is not None:
        # 2 rows: old on top, new below
        sheet = Image.new("RGB", (960, 512))
        sheet.paste(panels[0], (0, 0)); sheet.paste(panels[1], (320, 0)); sheet.paste(panels[2], (640, 0))
        sheet.paste(panels[0], (0, 256)); sheet.paste(panels[3], (320, 256)); sheet.paste(panels[4], (640, 256))
    else:
        sheet = Image.new("RGB", (960, 256))
        for i, p in enumerate(panels):
            sheet.paste(p, (i * 320, 0))
    sheet = sheet.resize((sheet.width * 2, sheet.height * 2), Image.NEAREST)
    os.makedirs(OUT, exist_ok=True)
    path = f"{OUT}/preview{letter}{tag}.png"
    sheet.save(path)
    return path


def load_old(letter):
    im = Image.open(f"{ORIG}/OperationJeffHeightmap{letter}.png").convert("RGB")
    return np.asarray(im)[:, :, 0].astype(int) // 8


def hillshade(z, angle_deg, gain=0.25):
    """Light a screen-space height field the way the art seems lit, to compare
    with the art itself. angle = direction the light travels (y down)."""
    import math
    gy, gx = np.gradient(z)
    t = math.radians(angle_deg)
    shade = 128 + (gx * math.cos(t) + gy * math.sin(t)) / max(1e-6, gain) * 32
    return Image.fromarray(shade.clip(0, 255).astype(np.uint8)).convert("RGB")


def tiles(images, path, scale=2, cols=None):
    cols = cols or len(images)
    rows = (len(images) + cols - 1) // cols
    w, h = images[0].size
    s = Image.new("RGB", (w * cols, h * rows))
    for i, im in enumerate(images):
        s.paste(im, ((i % cols) * w, (i // cols) * h))
    s = s.resize((s.width * scale, s.height * scale), Image.NEAREST)
    s.save(path)
    return path
