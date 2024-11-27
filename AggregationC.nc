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
  uint16_t taskParentID = -1;
  message_t output; //Needs to be declared here in order for the sendData task to work
  bool sendBusy = FALSE; //Flag to track if we are seding data at the moment


  //Final aggregation only runs at the base station

  command void Aggregator.chooseAggregation(){
    //Randomly decide between MAX and AVG (1 = MAX, 2 = AVG)
      RANDOM_NUM = call Random.rand16() % 2 + 1; // generates a 16-bit rand value and %2 + 1 limits it to 1 or 2
      dbg("Custom", "Aggregation function chosen: %d\n", RANDOM_NUM);
  }

  command void Aggregator.finalizeAggregation() {  
      // Perform aggregation based on RANDOM_NUM
      if (RANDOM_NUM == 1) {
        call Aggregator.aggregateMax(max_value);
      } else if (RANDOM_NUM == 2) {
        dbg("Custom","Node : %d has ACTUAL sum: %d and count: %d \n", TOS_NODE_ID,sum+sensorVal, count+1 );
        call Aggregator.aggregateAvg(sum+sensorVal, count+1); //Adding the values of the base station
      }
      sum = 0;
      count = 0;
      max_value = 0;
    }


//*********************** Data Exchange Functions *******************************//

  task void finishSendingData() {
    sensor_value_t* payload;
    error_t result;

    if(sendBusy){
      dbg("CustomSend", "Send already in progress for node %d\n", TOS_NODE_ID);
      return;
    }

    sendBusy = TRUE; //A send is starting

    payload= (sensor_value_t*)call Packet.getPayload(&output, sizeof(sensor_value_t));

    if (payload == NULL) {
        dbg("CustomSend", "Failed to get payload! by node: %d\n", TOS_NODE_ID);
        sendBusy = FALSE;
        return; 
    }

    payload->sensorValue = sum + sensorVal;
    payload->count = count + 1;

    //dbg("CustomSend", "node id here: %d pay sum: %d -- pay count:%d \n", TOS_NODE_ID, payload->sensorValue, payload->count);
    result = call AMSend.send(taskParentID, &output, sizeof(sensor_value_t));
    
    if (result != SUCCESS) {
        dbg("CustomSend", "AMSend failed for node %d, error: %d\n", TOS_NODE_ID, result);
        sendBusy = FALSE; // Reset flag
    }
  }


  //Function responsible for sending the data of all the child nodes of this sensor
  command void Aggregator.sendAggregatedData(uint16_t parentID) {
    taskParentID = parentID; // Set the module-level variable
    post finishSendingData(); // Post the task
  } 

  event void AMSend.sendDone(message_t *msg , error_t err){
    sendBusy = FALSE; //Reset the flag since message sent
    if(err == SUCCESS){
      //Reset aggregation variables on that sensor after sending successfully
      dbg("CustomSend", "Message sent successfully by node with id: %d to the parent %d\n", TOS_NODE_ID, taskParentID);
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
    //Process the received data
    call Aggregator.collectData(*receivedData);

    //dbg("Custom", "Node %d received data \n", TOS_NODE_ID);

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
    dbg("Custom","Node: %d collected data: sum = %d  count = %d  maxVal = %d  parent = %d\n", TOS_NODE_ID, sum, count, max_value,taskParentID);
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
    printf("AVG Aggregation Result: %u \n", average);
  }


//*********************** Functions to generate values *******************************//

  /*
  Function that generated a random int between 1 and 50
  */
  command uint16_t Aggregator.initialGenerateRandomSensorValue() {
      // Generate a random number in the range [1, 50]
      uint16_t baseValue = (call Random.rand16() % 50) + 1; // Generates a number between 1 and 50
      sensorVal = baseValue;
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
    sensorVal = baseValue;
    return newVal;
  }
	

}
