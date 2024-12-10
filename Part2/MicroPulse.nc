#include "micropulse.h"

interface MicroPulse {
    command void generateLoad();
    command void propagateCriticalPathToParent(uint16_t parentID);
    command void finalizePhaseOne();
}
