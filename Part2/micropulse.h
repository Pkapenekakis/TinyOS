#ifndef MICROPULSE_H
#define MICROPULSE_H

enum{
	AM_MICROPULSEP1MSG = 241,
    AM_MICROPULSEP2MSG = 242,
};

typedef nx_struct micropulseStruct
{
	nx_uint16_t criticalValue;

} micropulse_t;


#endif
