# GARAGE

This project uses an [ESP2866](http://www.esp8266.com) with [nodeMCU](http://nodemcu.com/index_cn.html) firmware to control a garage door.

Controlling a garage door from a microcontroller is easy. All you need to do is emulate a push button with a relay and wire it in parallel with the real push button on your garage door motor.

# Hardware

I bought a [kit from eBay](http://www.ebay.com/itm/281519483801?_trksid=p2059210.m2749.l2649) that came with most of what I needed:
* A cheap CH430 USB to Serial TTL adapter with 3.3V logic
* A bunch of female to female jumper wires and jumpers
* A somewhat useful carrying board that makes access to GPIO pins impossible as soldered.
* AM1117 5V to 3.3V power supply with 800 mA capacity.
* Female USB cable
* ESP-01 board, which gives access to 2 GPIO pins.

Separately, I bought [2 relays](http://www.ebay.com/itm/2pcs-3V-Relay-High-Level-Driver-Module-optocouple-Relay-Moduele-for-Arduino-/141523155660?) that can handle way more voltage and current than I need, but are handy because I can drive them with 3.3V logic of the ESP2866.

# Open issues

* When the ESP2866 powers up, both GPIO pins are in input mode, which the relay reads as logic high. That's not good, as it would trigger a garage door opening! I need to invert the logic. What's the easiest and cheapest way to do this?
