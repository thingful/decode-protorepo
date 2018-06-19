# Proposal - a proposal for defining entitlements DECODE IoT Pilot

This document contains a brief and high level design approach to defining and
working with entitlements for the DECODE IoT Pilot. The following information
was used in order to come up with a refined protocol buffer definition for
the service interface, so the information shown below is incomplete and
slightly disjointed.

For a clearer view of what is being proposed below I recommend looking at the
protobuf definition in the `devicereg` folder of this repository called
`devicereg.proto`.

## What does the incoming data look like for SmartCitizen?

An example data packet published by SmartCitizen:

```json
{
  "data": [
    {
      "recorded_at": "2018-06-03T22:26:02Z",
      "sensors": [
        {
          "id": 10,
          "value": 100
        },
        {
          "id": 29,
          "value": 67.02939
        },
        {
          "id": 13,
          "value": 74.65033
        },
        {
          "id": 12,
          "value": 22.41268
        },
        {
          "id": 14,
          "value": 5.29416
        }
      ]
    }
  ]
}
```

Key points here is that it is a single JSON object with a `data` containing a
single value array. The one element in this array is another single JSON
object containing two fields: `recorded_at` and `sensors`. `recorded_at`
contains the timestamp of the data shown; `sensors` is more interesting as it
contains an array of JSON objects, each with an `id` and a `value` field.
`id` is a reference to a specific sensor type - details of which can be
obtained via the SmartCitizen API.

So here we have:

- 10 - battery level (percentage)
- 29 - microphone sound level (dBC)
- 13 - humidity (percentage of the total amount of moisture the air can hold)
- 12 - air temperature (celsius)
- 14 - ambient light levels (lux)

## Permitted entitlements

- for a field, whether to share this field or not. If not included then this
  field should not be written to the datastore at all, if included it might be
  eligible for other processing
- for a field, defining a binning function that categorises the value
  received for that field into a specific bucket, e.g. for noise level we might
  group inputs into either below 40 dBC or above 40 dBC.
- for a field apply a moving average based on some arbitrary time window.
  This means for the field we must be able to specify the time window to be
  applied

## Example entitlements

- share sound level and light level without filtering:

```json
[{ "sensorId": 29, "action": "SHARE" }, { "sensorId": 14, "action": "SHARE" }]
```

- share sound level, binning into either below 40 dBC or above 40 dBC:

```json
[{ "sensorId": 29, "action": "BIN", "buckets": [40] }]
```

- share sound level, binning into either below 40 dbC, between 40 dBC and 100
  dBC, or above 100 dBC, share 15 minute moving average of ambient light

```json
[
  { "sensorId": 29, "action": "BIN", "buckets": [40, 100] },
  { "sensorId": 14, "action": "MOVING_AVG", "interval": 900 }
]
```

In the above we are assuming the simple IoT pilot specific case, where we
have a fixed list of channel ids that all device streams will emit, we don't
need to worry about the structure of the incoming events (as this is also
fixed).

## Issues

The above method for specifying an entitlement assumes we ahead of time know
the list of sensor types that SmartCitizen will be publishing. Nothing in the
above model would work for generic IoT data messages that could be coming
from anywhere. One approach to making this more general might be to change
the sensorId field to being a JSON path expression for example meaning an
entitlement could be applied to arbitrary JSON messages being received by the
system.
