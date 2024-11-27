#ifndef SENSORVALUE_H
#define SENSORVALUE_H

enum{
	AM_SENSORVAL = 240,
};

typedef nx_struct sensor_value
{
	nx_uint16_t sensorValue;
	nx_uint16_t maxSensorValue;
	nx_uint8_t count;
} sensor_value_t;

#endif
