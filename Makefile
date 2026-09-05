INSTALL_PATH=$(shell pwd)/../nextsync12/server/home

CC=zcc
AS=zcc
SUBTYPE=nex
TARGET=+zxn
CLIB=sdcc_iy
VERBOSITY=-vn
PRAGMA_FILE=zpragma.inc
INCLUDES=
# NOTE: --fomit-frame-pointer is deliberately NOT used. zsdcc 4.5 ignored it and always
# built IX frames; 4.6 honours it and addresses locals SP-relatively, but miscompiles that
# path - it emits a dead "ld hl,N / add hl,sp" that clobbers the pointer a following
# "dec hl" chain relies on, so an operand is read (N-M) bytes low, off the end of the
# frame into the return address (broke layer2box/layer2roundedBox). Omitting the flag also
# keeps sdcc off IY, which jeffpos/zx0/copper-ro all assume they can clobber freely.
CFLAGS=$(TARGET) $(VERBOSITY) -c -SO3 --max-allocs-per-node200000 --math16 --constsegPAGE_28_POSTISR -compiler=sdcc -clib=$(CLIB) -pragma-include=$(PRAGMA_FILE) $(INCLUDES)
LDFLAGS=$(TARGET) $(VERBOSITY) -Cz"--nex-border 0" -Cz"--nex-loadbar 19" -Cz"--nex-screen resources/loadingScreen.nxi" -Cz"--clean" -compiler=sdcc -clib=$(CLIB) -pragma-include=$(PRAGMA_FILE) -lm --math16
ASFLAGS=$(TARGET) $(VERBOSITY) -c -float=ieee16
OBJDIR=build
SRC=src

OBJECTS = $(addprefix $(OBJDIR)/, \
	jeff.o \
	ctc.o \
	jeffpos.o \
	copper-ro.o \
	copper-rw.o \
	screen.o \
	bomb.o \
	stars.o \
	stats.o \
	music.o \
	effects.o \
	end_of_level.o \
	hud.o \
	keyboard.o \
	files.o \
	sprites.o \
	copper.o \
	leds.o \
	mouse.o \
	gameover.o \
	menu.o \
	game.o \
	levelinfo.o \
	sound.o \
	bonus.o \
	tilemap.o \
	tiles.o \
	main.o \
	assets.o \
	base.o \
	zx0.o \
	font.o \
	dma-ro.o \
	dma-rw.o \
	graphics-ro.o \
	graphics-rw.o \
	control-ro.o \
	control-rw.o \
	ctc-ro.o \
	ctc-rw.o \
	interrupts-ro.o \
	interrupts-rw.o \
	utility-ro.o \
	utility-rw.o \
	audio.o \
)

$(OBJDIR)/%.o: $(SRC)/%.c $(PRAGMA_FILE)
	$(CC) $(CFLAGS) -o $@ $<

$(OBJDIR)/%.o: $(SRC)/%.asm
	$(AS) $(ASFLAGS) -o $@ $<

all: OperationJeff

makedir:
	mkdir -p build

OperationJeff: makedir $(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $(OBJDIR)/OperationJeff.nex -create-app -subtype=$(SUBTYPE)

install: all
	cp $(OBJDIR)/OperationJeff.nex $(INSTALL_PATH)

clean:
	rm build/*
