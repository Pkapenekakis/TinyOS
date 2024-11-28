#include "SensorValue.h"

interface Aggregator {
  command void collectData(sensor_value_t sensorValue);
  command void chooseAggregation();
  command void finalizeAggregation();
  command void finalizeAggregationOptional();
  command void sendAggregatedData(uint16_t parentID);
  command uint16_t initialGenerateRandomSensorValue();
  command uint16_t generateRandomSensorValue();
  command void aggregateMax(uint16_t maxVal);
  command void aggregateAvg(uint16_t totalSum, uint8_t totalCount);
}
