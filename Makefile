INSTALL_PATH=$(shell pwd)/../nextsync12/server/home

CC=zcc
AS=zcc
SUBTYPE=nex
TARGET=+zxn
CLIB=sdcc_iy
VERBOSITY=-vn
LIBS=-lm --math16
PRAGMA_FILE=zpragma.inc
APPMAKE_ARGS=-Cz"--nex-border 0" -Cz"--nex-loadbar 19" -Cz"--nex-screen resources/loadingScreen.nxi" -Cz"--clean"
C_OPT_FLAGS=-SO3 --max-allocs-per-node200000 --math16 #--opt-code-size
INCLUDES=-I${ZCCCFG}/../../libsrc/_DEVELOPMENT/target/zxn
CFLAGS=$(TARGET) $(VERBOSITY) -c $(C_OPT_FLAGS) --constsegPAGE_28_POSTISR -compiler=sdcc -clib=$(CLIB) -pragma-include=$(PRAGMA_FILE) $(INCLUDES)
LDFLAGS=$(TARGET) $(VERBOSITY) -clib=$(CLIB) $(APPMAKE_ARGS) -pragma-include=$(PRAGMA_FILE) $(LIBS)
ASFLAGS=$(TARGET) $(VERBOSITY) -c -float=ieee16
EXEC=OperationJeff
EXEC_OUTPUT=$(EXEC).nex
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
	dma.o \
	files.o \
	sprites.o \
	copper.o \
	leds.o \
	mouse.o \
	gameover.o \
	font.o \
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
	graphics-ro.o \
	graphics-rw.o \
	utility.o \
	audio.o \
)

$(OBJDIR)/%.o: $(SRC)/%.c $(PRAGMA_FILE)
	$(CC) $(CFLAGS) -o $@ $<

$(OBJDIR)/%.o: $(SRC)/%.asm
	$(AS) $(ASFLAGS) -o $@ $<

all: $(EXEC)

$(EXEC): $(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $(OBJDIR)/$(EXEC_OUTPUT) -create-app -subtype=$(SUBTYPE)

install: all
	cp $(OBJDIR)/$(EXEC_OUTPUT) $(INSTALL_PATH)

clean:
	rm build/*

.PHONY: clean
