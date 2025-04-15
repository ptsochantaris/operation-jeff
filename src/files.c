#include "resources.h"

static byte previousMmu0;
static byte previousMmu1;
static byte filename[] = "OperationJeff.scores";

void prepareForEsxCall(void) {
    // disable write-through
    configLayer2(0);

    // page in ROM
    previousMmu0 = ZXN_READ_MMU0();
    previousMmu1 = ZXN_READ_MMU1();
    ZXN_WRITE_MMU0(255);
    ZXN_WRITE_MMU1(255);

    errno = 0;
}

void completedEsxCall(void) {
    errno = 0;

    // page out ROM
    ZXN_WRITE_MMU0(previousMmu0);
    ZXN_WRITE_MMU1(previousMmu1);

    // re-enable write-through
    configLayer2(1);
}

void esxDosRomSetup(void) {
    // Normally ROM is paged out, but when we page it in we want it to
    // be the ROM3 (i.e. valilla 48k speccy) which esxdos API requires
    z80_outp(0x1FFD, 1 << 2); // high bit
    z80_outp(0x7FFD, 1 << 4); // low bit
}

void persistData(byte *src, int len) {
    prepareForEsxCall();
    byte handle = esx_f_open(filename, ESX_MODE_WRITE | ESX_MODE_OPEN_CREAT_TRUNC);
    if(!errno) {
        esx_f_write(handle, src, len);
        esx_f_close(handle);
    }
    completedEsxCall();
}

void fetchData(byte *dst, int len) {
    prepareForEsxCall();
    byte handle = esx_f_open(filename, ESX_MODE_READ);
    if(!errno) {
        esx_f_read(handle, dst, len);
        esx_f_close(handle);
    }
    completedEsxCall();
}
