INSTALL_PATH=$(shell pwd)/../nextsync12/server/home

CC=zcc
AS=zcc
SUBTYPE=nex
TARGET=+zxn
CLIB=sdcc_iy
VERBOSITY=-vn
LIBS=-lm --math16
PRAGMA_FILE=zpragma.inc
APPMAKE_ARGS=-Cz"--nex-border 0" -Cz"--nex-loadbar 19" -Cz"--nex-screen resources/loadingScreen.nxi"
C_OPT_FLAGS=-SO3 --max-allocs-per-node200000 --math16 #--opt-code-size
INCLUDES=-I${ZCCCFG}/../../libsrc/_DEVELOPMENT/target/zxn
CFLAGS=$(TARGET) $(VERBOSITY) -c $(C_OPT_FLAGS) --constsegPAGE_28 -compiler sdcc -clib=$(CLIB) -pragma-include:$(PRAGMA_FILE) $(INCLUDES)
LDFLAGS=$(TARGET) $(VERBOSITY) -clib=$(CLIB) $(APPMAKE_ARGS) -pragma-include:$(PRAGMA_FILE) $(LIBS)
ASFLAGS=$(TARGET) $(VERBOSITY) -c -float=ieee16
EXEC=OperationJeff
EXEC_OUTPUT=$(EXEC).nex
OBJDIR=build
SRC=src

OBJECTS = $(addprefix $(OBJDIR)/, \
	levelinfo.o \
	effects.o \
	base.o \
	dma.o \
	screen.o \
	jeff.o \
	sprites.o \
	stars.o \
	leds.o \
	mouse.o \
	bomb.o \
	stats.o \
	hud.o \
	font.o \
	copper.o \
	menu.o \
	gameover.o \
	game.o \
	sound.o \
	noteFrequencies.o \
	bonus.o \
	tilemap.o \
	tiles.o \
	main.o \
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
