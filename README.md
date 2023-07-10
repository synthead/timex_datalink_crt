# Timex Datalink CRT data transfer library for Ruby

Here's a Ruby library for syncing optical Timex Datalink devices using a CRT monitor!  This library produces graphics that are functionally-compatible to the original Timex Datalink software as demonstrated in [the Timex Datalink watch commercial](https://www.youtube.com/watch?v=p3Pzxmq-JLM).  Simply hold your watch up to your monitor and sync your data over light!

<image src="https://user-images.githubusercontent.com/820984/188436622-8cac39c7-9edc-4d92-a8c7-cbe9774cb691.jpg" width="600px">

The graphics are drawn using a modern SDL2 implementation in fullscreen.  Here's a still from a real transfer!

<image src="https://user-images.githubusercontent.com/820984/206843306-73386f0b-19fb-449a-a4c8-6de27b860812.png" width="600px">

# Usage

This library consumes packets compiled with [timex\_datalink\_client](https://github.com/synthead/timex_datalink_client).  Here is an example that will emit graphics for the current time in both the local time zone and UTC:

```ruby
require "timex_datalink_client"
require "timex_datalink_crt"

time_local = Time.now
time_utc = time_local.dup.utc

models = [
  TimexDatalinkClient::Protocol3::Sync.new,
  TimexDatalinkClient::Protocol3::Start.new,

  TimexDatalinkClient::Protocol3::Time.new(
    zone: 1,
    time: time_local,
    is_24h: false,
    date_format: "%y-%m-%d"
  ),
  TimexDatalinkClient::Protocol3::Time.new(
    zone: 2,
    time: time_utc,
    is_24h: true,
    date_format: "%y-%m-%d"
  ),

  TimexDatalinkClient::Protocol3::End.new
]

client = TimexDatalinkClient.new(models: models)
crt = TimexDatalinkCrt.new(packets: client.packets)

crt.draw_packets
```

# CRT display requirement

**A CRT monitor is required** for the light to be emitted from this library correctly.  CRTs use electron guns that draw scan lines one-by-one from top to bottom, then they return to the top in preparation for the next frame.  This means that the electron guns turn on when they're drawing a white line, and and turn off when they're drawing the black background.  This produces flashing light as the graphics are drawn, which is ultimately received by the optical sensor and decoded by the Timex Datalink device.

LCD and OLED monitors will not work because each frame is drawn almost instantaneously without an electron beam, so the picture does not "flash" as it is drawn like a CRT.  Don't have a CRT monitor?  You can still write data to your Timex Datalink devices with [a USB Notebook Adapter emulator made from a Teensy LC](https://github.com/synthead/timex-datalink-arduino)!
