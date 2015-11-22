# [nodemcu-httpserver](https://github.com/marcoskirsch/nodemcu-httpserver)
A (very) simple web server written in Lua for the ESP8266 running the NodeMCU firmware.

## Features

* GET, POST, PUT and minor changes to support other methods
* Multiple MIME types
* Error pages (404 and others)
* Server-side execution of Lua scripts
* Query string argument parsing with decoding of arguments
* Serving .gz compressed files
* HTTP Basic Authentication
* Decoding of request bodies in both application/x-www-form-urlencoded and application/json (if cjson is available)

## How to use

1. Upload server files using [nodemcu-uploader](https://github.com/kmpm/nodemcu-uploader).
   The easiest is to use GNU Make with the bundled Makefile. Open the Makefile and modify the
   user configuration to point to your nodemcu-uploader script and your serial port.
   Type the following to upload the server code, init.lua (which you may want to modify),
   and some example files:

         make upload_all

   If you only want to upload the server code, then type:

         make upload_server

   And if you only want to upload the http files:

         make upload_http

   Restart the server. This will execute init.lua which will compile the server code.
   Then, assuming init.lua doesn't have it, start the server yourself by typing:

         dofile("httpserver.lc")(80)

   In this example, 80 is the port your server is listening at, but you can change it.

2. Want to upload your own files? Move them to the http/ folder. Be careful though,
   the flash memory seems to fill up quickly and get corrupted.

   All the files you upload must be prefixed with "http/". Wait, what?

   Yes: NodeMCU's filesystem does not support folders, but filenames *can* contain slashes.
   Only files that begin with "http/" will be accessible through the server.

3. Visit your server from a web browser.

   __Example:__ Say the IP for your ESP8266 is 2.2.2.2 and the server is
   running in the default port 80. Go to (http://2.2.2.2/index.html)[http://2.2.2.2/index.html] using your web browser.
   The ESP8266 will serve you with the contents of the file "http/index.html" (if it exists). If you visit the root (/)
   then index.html is served. By the way, unlike most HTTP servers, nodemcu_httpserver treats the URLs in a
   case-sensitive manner.

4. How to use HTTP Basic Authentication.

   Enable and configure HTTP Basic Authentication by editing "httpserver-conf.lua" file.

   When enabled, HTTP Basic Authentication is global to every file served by the server.

   Remember that HTTP Basic Authentication is a very basic authentication protocol, and should not be
   considered secure if the server is not using encryption, as your username and password travel
   in plain text.

## How to create dynamic Lua scripts

   Similar to static files, upload a Lua script called "http/[name].lua where you replace [name] with your script's name.
   The script should return a function that takes two parameters:

      return function (connection, args)
         -- code goes here
      end

   Use the _connection_ parameter to send the response back to the client. Note that you are in charge of sending the HTTP header.
   The _args_ parameter is a Lua table that contains any arguments sent by the client in the GET request.

   For example, if the client requests _http://2.2.2.2/foo.lua?color=red_ then the server will execute the function
   in your Lua script _foo.lua_ and pass in _connection_ and _args_, where _args.color = "red"_.

   Look at the included example scripts for more ideas.

### Example: Garage door opener

#### Purpose

   This is a bundled example that shows how to use nodemcu-httpserver
   together with server-side scripting to control something with the
   ESP8266. In this example, we will pretend to open one of two garage doors.

   Your typical [garage door opener](http://en.wikipedia.org/wiki/Garage_door_opener)
   has a wired remote with a single button. The button simply connects to
   two terminals on the electric motor and when pushed, the terminals are
   shorted. This causes the motor to open or close.

#### Hardware description

   This example assumes that GPIO1 and GPIO2 on the ESP8266 are connected each to a relay
   that can be controlled. How to wire such thing is outside of the scope of this document
   [but information is easily found online](https://www.google.com/search?q=opening+a+garage+door+with+a+microcontroller).
   The relays are controlled by the microcontroller and act as the push button,
   and can actually be connected in parallel with the existing mechanical button.

#### Software description

   This example consists of the following files:

   * **garage_door_opener.html**: Static HTML displays a button with a link
   to the garage_door_opener.lua script. That's it!
   * **garage_door_opener.css**: Provides styling for garage_door_opener.html
   just so it looks pretty.
   * **garage_door_opener.lua**: Does the actual work. The script first sends
   a little javascript snippet to redirect the client back to garage_door_opener.html
   and then toggles the GPIO2 line for a short amount of time (roughly equivalent to
   the typical button press for opening a garage door) and then toggles it back.
   * **apple-touch-icon.png**: This is optional. Provides an icon that
   will be used if you "Add to Home Screen" the demo on an iPhone. Now it looks like an app!

#### Security implications

   Be careful permanently installing something like this in your home. The server provides
   no encryption. Your only layer of security is the WiFi network and anyone with access
   to it could open or close your garage, enter your home, and steal your flatscreen TV.

   This script is provided simply as an educational example and you should treat accordingly.

## Not supported

* ~~Other methods: HEAD, POST, PUT, DELETE, TRACE, OPTIONS, CONNECT, PATCH~~
* Encryption
* Multiple users (HTTP Basic Authentication)
* Only protect certain directories (HTTP Basic Authentication)

## Notes on memory usage.

   The chip is very, very memory constrained.

   * Use nodemcu-firmware dev096 or newer with as few optional modules as possible.
   Older versions have very little free RAM.

   * Use a firmware build without floating point support. This takes up a good chunk of RAM as well.
   In the (nodemcu-firmware releases page)[https://github.com/nodemcu/nodemcu-firmware/releases] these
   would be the ones with the term "integer" in them. If you are building it yourself then we'll assume
   you know what you're doing.

   * Any help reducing the memory needs of the server without crippling its functionality is appreciated!

   * Compile your Lua scripts in order to reduce their memory usage. The server knows to serve and treat
   both .lua and .lc files as scripts.
