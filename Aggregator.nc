interface Aggregator {
  command void collectData(uint16_t sensorValue);
  command void finalizeAggregation();
  command void sendAggregatedData();
  command uint16_t initialGenerateRandomSensorValue();
  command uint16_t generateRandomSensorValue(uint16_t baseValue);
  command void aggregateMax(uint16_t maxVal);
  command void aggregateAvg(uint16_t totalSum, uint8_t totalCount);
}