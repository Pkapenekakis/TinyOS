#include "SimpleRoutingTree.h"
#include "SensorValue.h"

configuration SRTreeAppC @safe() { }
implementation{
	components SRTreeC;
  //@Pkapenekakis, Gpiperakis
  components MicroPulseC;
  components AggregationC;
  components RandomC;  // Random number generation
  

#if defined(DELUGE) //defined(DELUGE_BASESTATION) || defined(DELUGE_LIGHT_BASESTATION)
	components DelugeC;
#endif

#ifdef PRINTFDBG_MODE
		components PrintfC;
#endif
	components MainC, ActiveMessageC, SerialActiveMessageC, LedsC;
	components new TimerMilliC() as Led0TimerC;
	components new TimerMilliC() as Led1TimerC;
	components new TimerMilliC() as Led2TimerC;
	components new TimerMilliC() as RoutingMsgTimerC;
	components new TimerMilliC() as LostTaskTimerC;
    components new TimerMilliC() as AggregationTimerC; //Timer for aggregation Epochs @Pkapenekakis, Gpiperakis
    components new TimerMilliC() as DepthDelayTimerC; //Timer for aggregation Epochs @Pkapenekakis, Gpiperakis
    components new TimerMilliC() as Phase1TimerC; //Pkapenekakis Gpiperakis
	
	components new AMSenderC(AM_ROUTINGMSG) as RoutingSenderC;
	components new AMReceiverC(AM_ROUTINGMSG) as RoutingReceiverC;
	components new AMSenderC(AM_NOTIFYPARENTMSG) as NotifySenderC;
	components new AMReceiverC(AM_NOTIFYPARENTMSG) as NotifyReceiverC;

    components new AMSenderC(AM_SENSORVAL) as AggregationSenderC; //@Pkapenekakis, Gpiperakis
    components new AMReceiverC(AM_SENSORVAL) as AggregationReceiverC; //@Pkapenekakis, Gpiperakis
    //Micropulse
    components new AMSenderC(AM_MICROPULSEP1MSG) as MicroPulseP1Sender; //@Pkapenekakis, Gpiperakis
    components new AMReceiverC(AM_MICROPULSEP1MSG) as MicroPulseP1Receiver; //@Pkapenekakis, Gpiperakis
    components new AMSenderC(AM_MICROPULSEP2MSG) as MicroPulseP2Sender; //@Pkapenekakis, Gpiperakis
    components new AMReceiverC(AM_MICROPULSEP2MSG) as MicroPulseP2Receiver; //@Pkapenekakis, Gpiperakis
#ifdef SERIAL_EN
	components new SerialAMSenderC(AM_NOTIFYPARENTMSG);
	components new SerialAMReceiverC(AM_NOTIFYPARENTMSG);
#endif
	components new PacketQueueC(SENDER_QUEUE_SIZE) as RoutingSendQueueC;
	components new PacketQueueC(RECEIVER_QUEUE_SIZE) as RoutingReceiveQueueC;
	components new PacketQueueC(SENDER_QUEUE_SIZE) as NotifySendQueueC;
	components new PacketQueueC(RECEIVER_QUEUE_SIZE) as NotifyReceiveQueueC;
	
	SRTreeC.Boot->MainC.Boot;
	
	SRTreeC.RadioControl -> ActiveMessageC;
	SRTreeC.Leds-> LedsC;
	
	SRTreeC.Led0Timer-> Led0TimerC;
	SRTreeC.Led1Timer-> Led1TimerC;
	SRTreeC.Led2Timer-> Led2TimerC;
	SRTreeC.RoutingMsgTimer->RoutingMsgTimerC;
	SRTreeC.LostTaskTimer->LostTaskTimerC;


    SRTreeC.AggregationTimer -> AggregationTimerC; //Link the aggregation timer @Pkapenekakis, Gpiperakis
    SRTreeC.DepthDelayTimer -> DepthDelayTimerC;
    SRTreeC.Phase1Timer->Phase1TimerC; //Pkapenekakis Gpiperakis

    // Connect AggregationC to SRTreeC @Pkapenekakis, Gpiperakis
    SRTreeC.Aggregator -> AggregationC;
    AggregationC.Random -> RandomC;
    AggregationC.Packet -> ActiveMessageC;
    AggregationC.AMSend -> AggregationSenderC.AMSend;
    AggregationC.Receive -> AggregationReceiverC.Receive;

    SRTreeC.MicroPulse -> MicroPulseC;
    MicroPulseC.Random -> RandomC;
    MicroPulseC.Packet -> ActiveMessageC;
    MicroPulseC.AMSendP1 -> MicroPulseP1Sender.AMSend;
    MicroPulseC.ReceiveP1 -> MicroPulseP1Receiver.Receive;
    MicroPulseC.AMSendP2 -> MicroPulseP2Sender.AMSend;
    MicroPulseC.ReceiveP2 -> MicroPulseP2Receiver.Receive;
	
	SRTreeC.RoutingPacket->RoutingSenderC.Packet;
	SRTreeC.RoutingAMPacket->RoutingSenderC.AMPacket;
	SRTreeC.RoutingAMSend->RoutingSenderC.AMSend;
	SRTreeC.RoutingReceive->RoutingReceiverC.Receive;
	
	SRTreeC.NotifyPacket->NotifySenderC.Packet;
	SRTreeC.NotifyAMPacket->NotifySenderC.AMPacket;
	SRTreeC.NotifyAMSend->NotifySenderC.AMSend;
	SRTreeC.NotifyReceive->NotifyReceiverC.Receive;
	
#ifdef SERIAL_EN	
	SRTreeC.SerialReceive->SerialAMReceiverC.Receive;
	SRTreeC.SerialAMSend->SerialAMSenderC.AMSend;
	SRTreeC.SerialAMPacket->SerialAMSenderC.AMPacket;
	SRTreeC.SerialPacket->SerialAMSenderC.Packet;
	SRTreeC.SerialControl->SerialActiveMessageC;
#endif
	SRTreeC.RoutingSendQueue->RoutingSendQueueC;
	SRTreeC.RoutingReceiveQueue->RoutingReceiveQueueC;
	SRTreeC.NotifySendQueue->NotifySendQueueC;
	SRTreeC.NotifyReceiveQueue->NotifyReceiveQueueC;
	
}
