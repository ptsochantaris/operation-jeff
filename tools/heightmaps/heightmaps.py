#!/usr/bin/env python3
"""Generate Operation Jeff level heightmaps from the level art.

    heightmaps.py              generate every generated level (writes the PNGs)
    heightmaps.py L M          just those levels
    heightmaps.py --preview L  preview only, leave resources_original alone
    heightmaps.py --verify     check the packed maps in resources/ match
    heightmaps.py --list       which levels are generated, which hand-drawn

See README.md for the workflow and what each generator does.
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import numpy as np

from hmlib import REPO, load_old, preview, write_heightmap
import gen_b, gen_d, gen_i, gen_j, gen_p, gen_plates, gen_q


def first(result):
    return result[0] if isinstance(result, tuple) else result


GENERATORS = {
    "B": ("grid bent over a hump - traced grid-line bows", gen_b.generate),
    "D": ("sand dunes - shape from shading", gen_d.generate),
    "I": ("gold strands - brightness along the strands", gen_i.generate),
    "J": ("cracked soil - plates between cracks", gen_j.generate),
    "L": ("turf tiles - plates between grooves (calibration level)", lambda: gen_plates.generate("L")),
    "M": ("lava - rock plates between lava channels", lambda: gen_plates.generate("M")),
    "P": ("colour blobs - local contrast as hills", gen_p.generate),
    "Q": ("snow cliffs - judged levels, stepped cliffs", gen_q.generate),
}

# Kept as Paul drew them: the art gives a generator nothing reliable (README).
HAND_DRAWN = "ACEFGHKNO"


def generate(levels, write):
    for L in levels:
        cells = first(GENERATORS[L][1]())
        print(f"{L}: {GENERATORS[L][0]} - lift {cells.min()}..{cells.max()}, mean {cells.mean():.1f}")
        # preview against what's in resources_original now, i.e. before writing
        print(f"   preview {preview(L, cells, '', old=load_old(L))}")
        if write:
            print(f"   wrote   {write_heightmap(L, cells)}")


def verify(levels):
    from unzx0 import unzx0
    failures = 0
    for L in levels:
        packed_path = os.path.join(REPO, "resources", f"heightmap{L}.hm.zx0")
        packed = np.frombuffer(unzx0(open(packed_path, "rb").read()), np.uint8).reshape(64, 80)
        png = load_old(L)
        generated = first(GENERATORS[L][1]())
        stale_pack = int((packed != png).sum())
        stale_png = int((png != generated).sum())
        ok = stale_pack == 0 and stale_png == 0
        failures += not ok
        notes = []
        if stale_png:
            notes.append(f"PNG differs from generator in {stale_png} cells - rerun heightmaps.py {L}")
        if stale_pack:
            notes.append(f"packed map differs from PNG in {stale_pack} cells - rerun makeAssets")
        print(f"{L}: {'ok' if ok else 'STALE'}" + ("" if ok else " - " + "; ".join(notes)))
    return failures


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("levels", nargs="*", help="level letters (default: all generated levels)")
    p.add_argument("--preview", action="store_true", help="write previews only, not the PNGs")
    p.add_argument("--verify", action="store_true", help="check resources/ against the PNGs and generators")
    p.add_argument("--list", action="store_true", help="list generated and hand-drawn levels")
    args = p.parse_args()

    if args.list:
        for L, (what, _) in sorted(GENERATORS.items()):
            print(f"{L}  generated: {what}")
        print(f"{', '.join(HAND_DRAWN)}  hand-drawn (see README)")
        return 0

    levels = [L.upper() for L in args.levels] or sorted(GENERATORS)
    unknown = [L for L in levels if L not in GENERATORS]
    if unknown:
        p.error(f"no generator for {', '.join(unknown)} (hand-drawn: {HAND_DRAWN})")

    if args.verify:
        return 1 if verify(levels) else 0
    generate(levels, write=not args.preview)
    return 0


if __name__ == "__main__":
    sys.exit(main())
