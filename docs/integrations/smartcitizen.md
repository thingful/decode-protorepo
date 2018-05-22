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

#### Using real data

You can use [Mosquitto](https://mosquitto.org/) to test your system:

* Listen to all MQTT data coming from other devices:

	`$ mosquitto_sub --host mqtt.smartcitizen.me --port 8883 --id decode_test_sub --topic device/sck/+/readings --cafile DST_Root_CA_X3.pem`

* Publish and subscribe to your own data:

	`$ mosquitto_pub --host mqtt.smartcitizen.me --port 8883 --id decode_test --topic device/sck/decode_test/readings --message '{"data":[{"recorded_at":"2018-01-11T17:52:51Z","sensors":[{"id":10,"value":95},{"id":29,"value":66.35234},{"id":13,"value":39.21178},{"id":12,"value":25.55512},{"id":14,"value":578.6607}]}]}' --qos 1 --cafile DST_Root_CA_X3.pem`

	`$ mosquitto_sub --host mqtt.smartcitizen.me --port 8883 --id decode_test_sub --topic device/sck/decode_test/readings --cafile DST_Root_CA_X3.pem`

* The connections use MQTTS (MQTT over TLS) and you will need to provide to mosquitto the path of your system DST_Root_CA_X3 root certificate as `--cafile DST_Root_CA_X3.pem`. You can also connect using plain MQTT by removing the `--cafile` option and changing the port to `--port 1883`.

### Registering Subscriptions

We use the EMQ 2.0(http://emqtt.io) MQTT broker:

* The system uses EMQ Shared Subscription system with Load balancing. This ensures messages distribution among currently active subscribers of a 'shared' topic.

* The broker supports wildcards on the subscription pattern. _i.e. `device/sck/+/readings` will subscribe to all the devices._

### Broker Authentication

As the current MQTT support is on an experimental phase we do not require authentication to access the broker and all the authentication happends at an application level via the `device_token`.