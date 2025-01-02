#include "micropulse.h"

interface MicroPulse {
    command void generateLoad();
    command void propagateCriticalPathToParent(uint16_t parentID);
    command void finalizePhaseOne();
    command uint16_t getCriticalPathValue();
    command uint16_t getLoadValue();
    command uint16_t getUpperBound();
}
