#ifndef MICROPULSE_H
#define MICROPULSE_H

enum{
	AM_MICROPULSEP1MSG = 240,
    AM_MICROPULSEP2MSG = 240,
};

typedef nx_struct micropulseP2Struct
{
	nx_uint16_t criticalValue;
    nx_uint8_t phase; //0 for phase 1, 1 for phase 2

} micropulseP2_t;

typedef nx_struct micropulseP1Struct
{
	nx_uint16_t criticalValue;

} micropulseP1_t;

#endif