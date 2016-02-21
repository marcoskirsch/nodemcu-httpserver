# [nodemcu-httpserver](https://github.com/marcoskirsch/nodemcu-httpserver)
A (very) simple web server written in Lua for the ESP8266 running the NodeMCU firmware.

[From the NodeMCU FAQ](https://nodemcu.readthedocs.org/en/dev/en/lua-developer-faq/#how-do-i-minimise-the-footprint-of-an-application):

> If you are trying to implement a user-interface or HTTP webserver in your ESP8266 then
> you are really abusing its intended purpose. When it comes to scoping your ESP8266
> applications, the adage Keep It Simple Stupid truly applies.
>
> -- <cite>[Terry Ellison](https://github.com/TerryE)</cite>, nodemcu-firmware maintainer,

Let the abuse begin.

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

   And if you only want to upload the server files:

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

## How to use server-side scripting using your own Lua scripts

   Similar to static files, upload a Lua script called "http/[name].lua where you replace [name] with your script's name.
   The script should return a function that takes three parameters:

      return function (connection, req, args)
         -- code goes here
      end

   Use the _connection_ parameter to send the response back to the client.
   Note that you are in charge of sending the HTTP header, but you can use the bundled httpserver-header.lua
   script for that. See how other examples do it.
   The _req_ parameter contains information about the request.
   The _args_ parameter is a Lua table that contains any arguments sent by the client in the GET request.

   For example, if the client requests _http://2.2.2.2/foo.lua?color=red_ then the server will execute the function
   in your Lua script _foo.lua_ and pass in _connection_ and _args_, where _args.color = "red"_.

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
   no encryption. Your only layers of security are the WiFi network's password and simple
   HTTP authentication which sends your password unencrypted.

   This script is provided simply as an educational example. You've been warned.

## Not supported

* Other methods: HEAD, DELETE, TRACE, OPTIONS, CONNECT, PATCH
* Encryption / SSL
* Multiple users (HTTP Basic Authentication)
* Only protect certain directories (HTTP Basic Authentication)
* nodemcu-firmware versions older 1.5.1 (January 2016) because that's what I tested on.

## Contributing

   Since this is a project maintained in my free time, I am pretty lenient on contributions.
   I trust you to make sure you didn't break existing functionality nor the shipping examples
   and that you add examples for new features. I won't test all your changes myself but I
   am very grateful of improvements and fixes. Open issues in GitHub too, that's useful.

   Please follow the coding style as close as possible:

   * No tabs, indent with 3 spaces
   * Unix (LF) line endings
   * Variables are camelCase
   * Follow file naming conventions
   * Use best judgement

## Notes on memory usage.

   The chip is very, very memory constrained.

   * Use a recent nodemcu-firmware with as few optional modules as possible.
   * Use a firmware build without floating point support. This takes up a good chunk of RAM as well.
   * Any help reducing the memory needs of the server without crippling its functionality is appreciated!
   * Compile your Lua scripts in order to reduce their memory usage. The server knows to serve and treat
   both .lua and .lc files as scripts.
