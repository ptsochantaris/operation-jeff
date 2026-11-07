# Heightmap generators

Generates level heightmaps (`resources_original/OperationJeffHeightmapX.png`) from the level art (`OperationJeffLevelX.png`). A heightmap is 80 x 64 cells of 4 x 4 px. Each cell lifts a Jeff standing there by 0-31 px. `makeAssets.swift` reads the PNG's red channel / 8. The generators write `k*8+4`, so that truncation has margin.

## Setup

```sh
python3 -m venv tools/heightmaps/.venv          # gitignored
tools/heightmaps/.venv/bin/pip install -r tools/heightmaps/requirements.txt
```

## Workflow

```sh
tools/heightmaps/.venv/bin/python tools/heightmaps/heightmaps.py        # all generated levels
tools/heightmaps/.venv/bin/python tools/heightmaps/heightmaps.py L      # just one
swift -O makeAssets.swift
make -j20 install
tools/heightmaps/.venv/bin/python tools/heightmaps/heightmaps.py --verify
```

Each run also writes `tools/heightmaps/previews/previewX.png` (gitignored) with two rows. The top row is the map that was in place before; the bottom row is the new one. Each row shows the art, the map, and the art with a ground grid draped over it the way the game lifts Jeffs. `--preview` writes only the previews.

`--verify` decodes `resources/heightmapX.hm.zx0` and checks it against the PNG and the generator, which catches a forgotten makeAssets run.

## How the game uses a map

A Jeff at sprite position (x, y) looks up the cell ((x+6)>>2, (y+14)>>2) and is drawn z px higher. When walking up or down it looks 4 px ahead instead (y+10 or y+18). So the map is indexed by the Jeff's ground position, while the art shows the surface on screen:

- **Screen-to-ground correction (`to_ground`).** A surface painted at screen row s with lift h belongs at ground row s+h. Most generators use this correction. L skips it, because it buries grooves thinner than the plate height (`NO_GROUND_WARP` in `gen_plates.py`). B is measured in ground space directly, and I's vertical ridges aren't affected by it.
- **Calibration (`GROUND_X_SHIFT`, `GROUND_Y_SHIFT` in `hmlib.py`).** Every map is shifted 8 px right and 2 px down. This was measured on hardware on level 7 (L), whose straight grooves in both directions and lack of a ground correction make any offset obvious. Use L to re-check the calibration. The gap between this and the code's geometry is unexplained.
- **Steep slopes.** A Jeff's z moves at most 2 per 2 px step. Walls steeper than 1:1 therefore make narrow dips shallower than drawn.

## Levels

| Level | Play order | Generator | Method |
|--|--|--|--|
| B | 3 | `gen_b.py` | Grid bent over a hump. A lifted horizontal grid line is drawn bowed upward by exactly its lift, so the generator traces the lines, measures each bow and interpolates between them. The result is already in ground space. |
| D | 5 | `gen_d.py` | Dunes, by shape from shading. The light's direction comes from edge asymmetry (the sharp lit-to-shadow edge is the crest). The wrong sign turns crests into troughs. |
| I | 6 | `gen_i.py` | Gold strands. Brightness is blurred along the strands, minus a broad blur to remove the lighting. |
| J | 11 | `gen_j.py` | Cracked soil. Cracks are segmented and plates rise with distance from them. |
| L | 7 | `gen_plates.py` | Turf tiles. Grooves are found by direction (the vertical ones are faint). No ground correction. |
| M | 15 | `gen_plates.py` | Rock plates between lava (lava is where red exceeds blue by more than 40). |
| P | 10 | `gen_p.py` | Posterised blobs. Local contrast makes each blob's lighter centre a hill. |
| Q | 12 | `gen_q.py` | Snow and rock cliffs. Each snow region is pinned to a judged level, and the cliffs are steps. The levels in `LEVELS` are judgement calls. |

A, C, E, F, G, H, K, N and O stay hand-drawn, because the art gives a generator nothing to measure:
- H and K are flat surfaces.
- C (grass), O (colour cloud) and F (wood grain) show no relief.
- A's ripples (about 3 px apart) are finer than the 4 px cells.
- E's blotches could be depth or just colour.
- G's central bowl already suits the sagging arc in the art.
- N's bands are a design choice; the fabric's pleats would make Jeffs jitter.

`unzx0.py` is a ZX0 decoder used by `--verify`.
