Smart Citizen Integration
=========================

## MQTT communication

Embedded devices communicate with the platform using MQTT messages via the MQTT broker at `mqtt.smartcitizen.me`.

It is also possible to publish data to the platform using the [REST API](http://developer.smartcitizen.me/#post-readings) but this will not be supported on the current integration.

### Readings Publish

Devices publish using the topic `device/sck/device_token:/readings` and the expected payload is of the following form:

```
{
  "data": [{
    "recorded_at": "2016-06-08 10:30:00",
    "sensors": [{ "id": 1, "value": 21 }]
  },{
    "recorded_at": "2016-06-08 10:35:00",
    "sensors": [{ "id": 1, "value": 22 }]
  }]
}
```

* Each device is identified by a unique `device_token`.

* Every device has sensor(s). A `sensor` is something on a device that can record data. This could be anything, some examples are - temperature, humidity, battery percentage, # wifi networks. A list of all the available sensors can be retrieve via the [API](http://developer.smartcitizen.me/#sensors).

* Messages must be published using QoS (Quality of Service) of 1.

### Registering Subscriptions

We use the EMQ 2.0(http://emqtt.io) MQTT broker:

* The system uses EMQ Shared Subscription system with Load balancing. This ensures messages distribution among currently active subscribers of a 'shared' topic.

* The broker supports wildcards on the subscription pattern. _i.e. `device/sck/+/readings` will subscribe to all the devices._

### Broker Authentication

As the current MQTT support is on an experimental phase we do not require authentication to access the broker and all the authentication happends at an application level via the `device_token`.