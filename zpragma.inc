#pragma startup = 31
#pragma printf = "%lu %d"

#pragma output startup = 31
#pragma output REGISTER_SP = 0             // move the stack to the top of memory

#pragma output CRT_ORG_CODE = 0x8000
#pragma output CRT_INITIALIZE_BSS = 0      // no bss init
#pragma output CRT_ORG_BSS = -1            // strip bss section from binary
#pragma output CRT_ENABLE_STDIO = 0
#pragma output CRT_ENABLE_COMMANDLINE = 0
#pragma output CRT_CORE_VERSION = 302000

#pragma output CLIB_EXIT_STACK_SIZE = 0     // get rid of the exit stack (no functions can be registered with atexit() )
#pragma output CLIB_MALLOC_HEAP_SIZE = 0    // disable malloc heap
#pragma output CLIB_STDIO_HEAP_SIZE  = 0    // do not create extra space for opening FILEs
#pragma output CRT_ENABLE_CLOSE = 0         // do not close open files on exit (at this time this has no effect)
#pragma output CRT_ENABLE_RESTART = 1       // This one shaves a few bytes off as you noted because the crt no longer has to put in code to restore HL', IY and im 1 mode.
