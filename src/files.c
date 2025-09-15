#include "resources.h"

static byte previousMmu1;

static void prepareForEsxCall(void) __z88dk_fastcall {
    // disable write-through
    configLayer2(0);

    // page in ROM
    previousMmu1 = ZXN_READ_MMU1();
    ZXN_WRITE_MMU0(255);
    ZXN_WRITE_MMU1(255);

    errno = 0;
}

static void completedEsxCall(void) __z88dk_fastcall {
    errno = 0;

    // page out ROM
    ZXN_WRITE_MMU0(28);
    ZXN_WRITE_MMU1(previousMmu1);

    // re-enable write-through
    configLayer2(1);
}

void esxDosRomSetup(void) __z88dk_fastcall {
    // Normally ROM is paged out, but when we page it in we want it to
    // be the ROM3 (i.e. valilla 48k speccy) which esxdos API requires
    z80_outp(0x1FFD, 1 << 2); // high bit
    z80_outp(0x7FFD, 1 << 4); // low bit

    ZXN_WRITE_MMU0(28);
}

void persistData(void *src, int len, const char *restrict filename) __z88dk_callee {
    if(len <= 0) return;

    prepareForEsxCall();
    byte handle = esx_f_open(filename, ESX_MODE_WRITE | ESX_MODE_OPEN_CREAT_TRUNC);
    if(!errno) {
        esx_f_write(handle, src, len);
        esx_f_close(handle);
    }
    completedEsxCall();
}

void fetchData(void *dst, int len, const char *restrict filename) __z88dk_callee {
    if(len <= 0) return;

    prepareForEsxCall();

    byte handle = esx_f_open(filename, ESX_MODE_READ);
    if(!errno) {
        struct esx_stat stsx;
        bzero(&stsx, sizeof(stsx));
        esx_f_fstat(handle, &stsx);
        if(stsx.size >= len) {
            esx_f_read(handle, dst, len);
        }
        esx_f_close(handle);
    }

    completedEsxCall();
}
