#include <stdio.h>
#include "SensorValue.h"

module AggregationC {
  //uses interface Boot;
  //uses interface Timer<TMilli> as AggregationTimer;
  uses interface Random; // For generating RANDOM_NUM
  uses interface Receive; //For receiving data from child nodes
  uses interface AMSend;
  uses interface Packet;
  provides interface Aggregator;
}

implementation {
  uint16_t sum = 0;
  uint8_t count = 0;
  uint16_t max_value = 0;
  uint16_t sensorVal = 0;
  uint8_t RANDOM_NUM = 2; // Placeholder for the random number (1 for MAX, 2 for AVG)
  //uint16_t previousValue = 25; //Random initial Value
  //bool firstEpoch = true; //flag to trach if it is the first epoch
  uint16_t taskParentID = -1;
  

  /*
  event void Boot.booted() {
    // Start the timer to trigger aggregation every 40 seconds
    call AggregationTimer.startPeriodic(40000); // 40,000 ms = 40 seconds
 	} */


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

  

  task void finishSendingData() {
    message_t msg;

    sensor_value_t* payload = (sensor_value_t*)call Packet.getPayload(&msg, sizeof(sensor_value_t));

    if (payload == NULL) {
        dbg("Custom", "Failed to get payload!\n");
        return; 
    }

    payload->sensorValue = sum;
    payload->count = count;

    dbg("Custom", "node id here: %d taskParentid: %d -- msg:%c --size: %d \n", TOS_NODE_ID, taskParentID,&msg, sizeof(sensor_value_t));
    //try and send the message, if it fails I handle it in the sendDone event
    call AMSend.send(taskParentID, &msg, sizeof(sensor_value_t));
  }


  //Function responsible for sending the data of all the child nodes of this sensor
  command void Aggregator.sendAggregatedData(uint16_t parentID) {
    taskParentID = parentID; // Set the module-level variable
    post finishSendingData(); // Post the task
  } 

  event void AMSend.sendDone(message_t *msg , error_t err){
    if(err == SUCCESS){
      //Reset aggregation variables on that sensor after sending successfully
      dbg("Custom", "Message sent successfully by node with id: %d. Resetting aggregation variables.\n", TOS_NODE_ID);
      sum = 0;
      count = 0;
      max_value = 0;   
    }else{
      dbg("Custom", "Send failed, reposting task. Error code: %d\n", err);
      post finishSendingData(); 
    }
  }
  

  //Receive data from child nodes
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    sensor_value_t* receivedData = (sensor_value_t*)payload;
    // Process the received data
    call Aggregator.collectData(*receivedData);

    return msg;
  }

  /* 
  Accepts sensor values, accumulates them for the AVG calculation, and keeps track of the maximum value.
  */
  command void Aggregator.collectData(sensor_value_t sensorData) {
    // Collect sensor data and aggregate
    sum += sensorData.sensorValue;
    count += sensorData.count; // Accumulate the count for AVG

    if (sensorData.sensorValue > max_value) {
      max_value = sensorData.sensorValue;
    }
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
