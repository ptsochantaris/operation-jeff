CC=zcc
AS=zcc
TARGET=+zxn
VERBOSITY=-vn
CLIB=sdcc_iy
SUBTYPE=nex
PRAGMA_FILE=zpragma.inc

C_OPT_FLAGS=-SO3 --max-allocs-per-node200000 --math16
#--opt-code-size

INCLUDES=\
-I/Users/ptsochantaris/Desktop/ZX/z88dk/libsrc/_DEVELOPMENT/target/zxn

LIBS=-lm --math16

CFLAGS=$(TARGET) $(VERBOSITY) -c $(C_OPT_FLAGS) --constsegPAGE_28 -compiler sdcc -clib=$(CLIB) -pragma-include:$(PRAGMA_FILE) $(INCLUDES)
LDFLAGS=$(TARGET) $(VERBOSITY) -clib=$(CLIB) -pragma-include:$(PRAGMA_FILE) $(LIBS)
ASFLAGS=$(TARGET) $(VERBOSITY) -c -float=ieee16

EXEC=OperationJeff
EXEC_OUTPUT=$(EXEC).nex
OBJDIR=build

OBJECTS = $(addprefix $(OBJDIR)/, \
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

$(OBJDIR)/%.o: %.c $(PRAGMA_FILE)
	$(CC) $(CFLAGS) -o $@ $<

$(OBJDIR)/%.o: %.asm
	$(AS) $(ASFLAGS) -o $@ $<

all: $(EXEC)

$(EXEC): $(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $(OBJDIR)/$(EXEC_OUTPUT) -create-app -subtype=$(SUBTYPE)

install: all
	cp $(OBJDIR)/$(EXEC_OUTPUT) ~/Desktop/ZX/nextsync12/server/home

clean:
	rm build/*

.PHONY: clean
