# Operation Jeff

A simple arcade game for the ZX Spectrum Next - Work in progress!

The code can be compiled with `make` and the z88dk toolchain. It is developed using Visual Studio Code.

More details will be added here soon.

### Instructions

Use the mouse to point and shoot. The bolts you fire land and explode shortly later, and will dematerialise any nearby Jeff.

Do not let any Jeff reach the edge of the screen, or you will lose health and eventually the game will be over. Once a certain number of Jeff is eliminated, you move onto the next area.

Shooting uses _charge_ which slowly replenishes over time. You can trade fire rate for charge speed (and the reverse) by using the mouse wheel.

Shoot bonuses for various benefits:
- Red cross: Replenish health
- Green cross: Replenish charge
- Black cross: Bonus points
- Yellow diamond: Smart bomb
- Blue clock: Freeze the Jeff for 5 seconds
- Black rectangle: Temporary shield from damage
- Purple umbrella-like-thingy: Pause drops for a moment
- Round yellow down arrow: Slow down the Jeff temporarily
- Orange concentric circles: Extended bomb range (for a limited number of shots)
- Circle with bolt in the middle: Supergun (fast rate, no charge cost, for a limited number of shots)

If a bolt explodes especially close enough to a Jeff you get a small bonus as well.

Press P to pause during the game.

|![Screenshot 1](screenshots/OperationJeffScreenshot1.jpg)|![Screenshot 2](screenshots/OperationJeffScreenshot2.jpg)|
|--|--|

|![Screenshot 3](screenshots/OperationJeffScreenshot3.jpg)|![Screenshot 4](screenshots/OperationJeffScreenshot4.jpg)|![Screenshot 5](screenshots/OperationJeffScreenshot5.jpg)|![Screenshot 6](screenshots/OperationJeffScreenshot6.jpg)|
|--|--|--|--|
|![Screenshot 7](screenshots/OperationJeffScreenshot7.jpg)|![Screenshot 8](screenshots/OperationJeffScreenshot8.jpg)|![Screenshot 9](screenshots/OperationJeffScreenshot9.jpg)|![Screenshot 10](screenshots/OperationJeffScreenshot10.jpg)|

### Resources

The game packs all its resources into a single NEX file. Almost all data, except the executable code and digial audio, is compressed using the zx0 compressor and decompressed at the time of use.

The resources are converted to native Next formats from the files in `resources_original` via the `convertResource.sh` script. This script performs these steps:

- Level backgrounds are converted from PNG to native Next using the `gfx2next` utility.
- Generated images and palettes are compressed using the `zx0` utility.
- Level heightmaps are converted from PNG to via the `convertHeightmaps.swift` script to *.hm files (which are just a raster of 8-bit brightness values).
- The converted assets are then scanned by the `makeAssets.swift` script which results in a generated `assets.asm` file with an accompanying `assets.h` file. The ASM file builds the binary blob with all the binary data, sorted to fill each memory page as much as possible, and the H file creates defines which are used in the game to refer to each resource's (paged-in) address, data length, and page.
- Finally the loading screen for the NEX is converted in a slightly different native format as required by the NEX spec.

### Graphic Layers

- The ULA is on top and handles the large "OSD" style messages that are displayed.
- Sprite layer handles the mouse pointer and JEFF hoardes.
- The tilemap handles the bonuses that appear in random locations.
- Layer2 is configured for "high res" 320x256 mode and used for the menus, in-game stats, and level backgrounds.

### Memory map

![Memory map diagram](screenshots/memory_map.png)

Like most z80 targetting software, the code makes heavy use of paging. This diagram may help make code and memory setup more understandable. The main strategy is:

#### The low 16k (`MMU0` and `MMU1`)

The ROM is configured as `ROM3`, which is the traditional 48k Sinclair ZX Spectrum ROM and is required by the ESX Dos API. However outside of making ESX Dos API calls, _the ROM is usually paged-out_. Instead the layout of the bottom 16k is this:

- `MMU0` is read-only and set to page 28, containing the ISR routine, and most constant values used in the program.
- `MMU1` is also read-only and mostly used for loading and buffering, like the compressed contents of levels or as the first half of the digital audio buffer.
- `MMU0` and `MMU1` are configured as write-only for writing to the Layer 2 display in 16k chunks.

#### The next 16k (`MMU2` and `MMU3`)

- `MMU2` would traditionally be the ULA on a Spectrum but that is shifted to page 10 and assigned to `MMU3` below. Instead this slot is either (a) used as an extension for 16k-size buffers starting at `MMU1`, like when loading sprites and playing audio loops, or (b) as a write destination for data when we're decompressing zx0 data read from `MMU1` such as level screens.
- `MMU3` would traditionally point to the tilemap on the ZX Spectrum Next, but most of the time we point it to page 10, which is to where the ULA has been relocated (so that `MMU1` and `MMU2` can form a contiguous memory space for DMAing when buffering). The game can flip between the two when required to modify each one.
- `MMU3` Acts as secondary buffer as well, currently used when loading palettes, as that can happen simultaneously while playing digital sound from the "main" buffer area at `MMU1` and `MMU2`.

#### The top 32k (`MMU4` -> `MMU7`)

- `MMU4` to `MMU7` hold the executable code and read/write variables, buffers, etc.
- The stack grows back from the end at $FFFF.

*All code (c) 2025 Paul Tsochantaris, published under the MIT license.*
