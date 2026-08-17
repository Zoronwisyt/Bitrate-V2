#include <stdio.h>

// This references the Swift function we exposed
extern void zoron_swift_entry(void);

// This tells iOS to run this function the EXACT millisecond the dylib is loaded into memory
__attribute__((constructor))
static void ZoronDylibConstructor(void) {
    printf("[ZoronBitrateBooster] C Constructor Fired! Waking up Swift engine...\n");
    zoron_swift_entry();
}
