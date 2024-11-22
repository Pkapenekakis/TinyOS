#include <stdio.h>

module AggregationC {
  //uses interface Boot;
  //uses interface Timer<TMilli> as AggregationTimer;
  uses interface Random; // For generating RANDOM_NUM
  uses interface Receive; //For receiving data from child nodes
  uses interface Packet;
  provides interface Aggregator;
}

implementation {
  uint16_t sum = 0;
  uint8_t count = 0;
  uint16_t max_value = 0;
  uint16_t sensorVal = 0;
  uint8_t RANDOM_NUM = 1; // Placeholder for the random number (1 for MAX, 2 for AVG)
  //uint16_t previousValue = 25; //Random initial Value
  //bool firstEpoch = true; //flag to trach if it is the first epoch
  

  /*
  event void Boot.booted() {
    // Start the timer to trigger aggregation every 40 seconds
    call AggregationTimer.startPeriodic(40000); // 40,000 ms = 40 seconds
 	} */


  /* 
  Accepts sensor values, accumulates them for the AVG calculation, and keeps track of the maximum value.
  */
  command void Aggregator.collectData(uint16_t sensorValue) {
    // Collect sensor data and aggregate
    sum += sensorValue;
    count += 1;

    if (sensorValue > max_value) {
      max_value = sensorValue;
    }
  }

  //Final aggregation only runs at the base station
    command void Aggregator.finalizeAggregation() {  
      //Randomly decide between MAX and AVG (1 = MAX, 2 = AVG)
      RANDOM_NUM = call Random.rand16() % 2 + 1; // generates a 16-bit rand value and %2 + 1 limits it to 1 or 2

      // Perform aggregation based on RANDOM_NUM
      if (RANDOM_NUM == 1) {
        call Aggregator.aggregateMax(max_value);
      } else if (RANDOM_NUM == 2) {
        call Aggregator.aggregateAvg(sum, count);
      }
      sum = 0;
      count = 0;
      max_value = 0;
    }


//*********************** Data Exchange Functions *******************************//
/*
  //Function responsible for sending the data of all the child nodes of this sensor
  command void Aggregator.sendAggregatedData() {
    message_t msg;
    uint16_t* payload = (uint16_t*)call Packet.getPayload(&msg, sizeof(uint16_t));
    *payload = sum; // Send the sum as the aggregated result

    //call AMSend.send(parentID, &msg, sizeof(uint16_t));

    //Reset aggregation variables after sending
    sum = 0;
    count = 0;
    max_value = 0;
  } 

*/

command void Aggregator.sendAggregatedData() {}

  // Receive data from child nodes
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    uint16_t* receivedValue = (uint16_t*)payload;
    call Aggregator.collectData(*receivedValue);
    return msg;
  }

//*********************** Aggregation Functions *******************************//

  /* 
  Outpits the MAX result to the console
  */
  command void Aggregator.aggregateMax(uint16_t maxVal) {
    printf("MAX Aggregation Result: %u\n", maxVal);
  }

  /* 
  Outputs the AVG result to the console
  */
  command void Aggregator.aggregateAvg(uint16_t totalSum, uint8_t totalCount) {
    uint16_t average = (totalCount > 0) ? totalSum / totalCount : 0; //We check if data is collected in order to protect against errors
    printf("AVG Aggregation Result: %u,      Count is: %d\n", average, count);
  }


//*********************** Functions to generate values *******************************//

  /*
  Function that generated a random int between 1 and 50
  */
  command uint16_t Aggregator.initialGenerateRandomSensorValue() {
      // Generate a random number in the range [1, 50]
      uint16_t baseValue = (call Random.rand16() % 50) + 1; // Generates a number between 1 and 50
      return baseValue;
  }

  /*
  Function that generates a random int between 1 and 50
  Makes sure that every epoch the new value generated has less than 30% variation
  */
  command uint16_t Aggregator.generateRandomSensorValue(uint16_t baseValue) {
    // Calculate a 30% variation of the base value
    uint16_t minBase = baseValue - (baseValue * 30 / 100); // 30% of the base value
    uint16_t maxBase = baseValue + (baseValue * 30 / 100); // 30% of the base value
    uint16_t newVal;

    do{
      newVal = (call Random.rand16() % 50) + 1; // Generates a number between 1 and 50
    }while(newVal < minBase || newVal > maxBase);
    
    return newVal;
  }
	

}
