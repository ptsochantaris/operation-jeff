INSTALL_PATH=$(shell pwd)/../nextsync12/server/home

CC=zcc
AS=zcc
SUBTYPE=nex
TARGET=+zxn
CLIB=sdcc_iy
VERBOSITY=-vn
PRAGMA_FILE=zpragma.inc
INCLUDES=-I${ZCCCFG}/../../libsrc/newlib/target/zxn
CFLAGS=$(TARGET) $(VERBOSITY) -c -SO3 --max-allocs-per-node200000 --math16 --fomit-frame-pointer --constsegPAGE_28_POSTISR -compiler=sdcc -clib=$(CLIB) -pragma-include=$(PRAGMA_FILE) $(INCLUDES)
LDFLAGS=$(TARGET) $(VERBOSITY) -Cz"--nex-border 0" -Cz"--nex-loadbar 19" -Cz"--nex-screen resources/loadingScreen.nxi" -Cz"--clean" -compiler=sdcc -clib=$(CLIB) -pragma-include=$(PRAGMA_FILE) -lm --math16
ASFLAGS=$(TARGET) $(VERBOSITY) -c -float=ieee16
OBJDIR=build
SRC=src

OBJECTS = $(addprefix $(OBJDIR)/, \
	jeff.o \
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
	utility.o \
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
