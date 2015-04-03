# nodemcu-httpserver
A (very) simple web server written in Lua for the ESP8266 firmware NodeMCU.

## Features

* GET
* Multiple MIME types
* Error pages (404 and others)
* Server-side execution of Lua scripts
* Query string argument parsing
* Serving .gz compressed files

## How to use

1. Upload server files using [nodemcu-uploader](https://github.com/kmpm/nodemcu-uploader) or similar.
   Or, even better, use GNU Make with the bundled makefile. Type the following to upload
   server code, init.lua (which you may want to modify), and some example files:

         make upload

   If you only want to upload the server code, then type:

         make upload_server

   And if you only want to upload the http files:

         make upload_http

   Restart the server. This will execute init.lua which will compile the server code.
   Then, assuming init.lua doesn't have it, start the server yourself by typing:

         dofile("httpserver.lc")(80)

   In this example, 80 is the port your server is listening at but you can change it.

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

## How to create dynamic Lua scripts

   Similar to static files, upload a Lua script called "http/[name].lua where you replace [name] with your script's name.
   The script should return a function that takes two parameters:

      return function (connection, args)
         -- code goes here
      end

   Use the _connection_ parameter to send the response back to the client. Note that you are in charge of sending the HTTP header.
   The _args_ parameter is a Lua table that contains any arguments sent by the client in the GET request.

   For example, if the client requests _http://2.2.2.2/foo.lua?color=red_ then the server will execute the function
   in your Lua script _foo.lua_ and pass in _connection_ and _args_, where _args.color == "red"_.

   If you are going to be sending lots (as in over a KB) of data, you should yield the thread/coroutine every now and then
   in order to avoid overflowing the buffer in the microcontroller. Use:

      coroutine.yield()

   The easiest is to check out the included example scripts for more ideas.

### Example: Garage door opener

#### Purpose

   This is a bundled example that shows how to use nodemcu-httpserver
   together with server-side scripting to control something with the
   ESP8266. In this example, we will pretend to open a garage door.
   This is a very simple example that doesn't even use arguments passed
   in the request (see example args.lua for that).

   Your typical [garage door opener](http://en.wikipedia.org/wiki/Garage_door_opener)
   has a wired remote with a single button. The button simply connects to
   two terminals on the electric motor and when pushed, the terminals are
   shorted. This causes the motor to open or close.

#### Hardware description

   This example assumes that GPIO2 on the ESP8266 is connected to a relay
   that can be controlled. How to wire such thing is outside of the scope
   of this document [but information is easily found online]
   (https://www.google.com/search?q=opening+a+garage+door+with+a+microcontroller).
   The relay is controlled by the microcontroller and acts as the button,
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
   will be used if you "Add to Home Screen" the demo. Now it looks like an app!`

#### Security implications

   Be careful permanently installing something like this in your home. The
   scripts use no authentication and no encryption. Your only layer of
   security is your wifi network and anyone with access to it could open
   or close your garage, enter your home, and steal your flatscreen TV.

   This script is provided simply as an educational example and you should
   treat accordingly.

## Not supported

* Other methods: HEAD, POST, PUT, DELETE, TRACE, OPTIONS, CONNECT, PATCH
* HTTP authentication
* Encryption

## Notes on memory usage.

   The chip is very, very memory constrained. You must use a build of nodemcu-firmware recent enough to support
   node.compile() since the server expects all server scripts to be compiled.

   * It is recommended you use a firmware build without support for floating point.
   In the (nodemcu-firmware releases page)[https://github.com/nodemcu/nodemcu-firmware/releases] these would be the ones
   with the term "integer" in them. If you want to build your own, then edit file nodemcu-firmware/app/lua/luaconf.h right
   around line 572 (line number may change) by adding

         #define LUA_NUMBER_INTEGRAL

     Then rebuild and re-flash the firmware.

   * Any help reducing the memory needs of the server without crippling its features are appreciated!

   * You can compile your Lua scripts in order to reduce their memory usage. The server knows to treat
   both .lua and .lc files as scripts.
