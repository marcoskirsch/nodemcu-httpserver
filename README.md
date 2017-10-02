# [nodemcu-httpserver](https://github.com/marcoskirsch/nodemcu-httpserver)
A (very) simple web server written in Lua for the ESP8266 running the NodeMCU firmware.

[From the NodeMCU FAQ](https://nodemcu.readthedocs.org/en/dev/en/lua-developer-faq/#how-do-i-minimise-the-footprint-of-an-application):

> If you are trying to implement a user-interface or HTTP webserver in your ESP8266 then
> you are really abusing its intended purpose. When it comes to scoping your ESP8266
> applications, the adage Keep It Simple Stupid truly applies.
>
> -- <cite>[Terry Ellison](https://github.com/TerryE)</cite>, nodemcu-firmware maintainer

Let the abuse begin.

## Features

* GET, POST, PUT (other methods can be supported with minor changes)
* Multiple MIME types
* Error pages (404 and others)
* *Server-side execution of Lua scripts*
* Query string argument parsing with decoding of arguments
* Serving .gz compressed files
* HTTP Basic Authentication
* Decoding of request bodies in both application/x-www-form-urlencoded and application/json (if cjson is available)

## How to use

1. Modify your local copy of the configuration file httpserver-conf.lua.

2. Upload server files using [nodemcu-uploader](https://github.com/kmpm/nodemcu-uploader).
   The easiest is to use GNU Make with the bundled Makefile. Open the Makefile and modify the
   user configuration to point to your nodemcu-uploader script and your serial port.
   Type the following to upload the server code, init.lua (which you may want to modify),
   and some example files:

         make upload_all

   If you only want to upload just the server code, then type:

         make upload_server

   And if you only want to upload just the files that can be served:

         make upload_http

   Restart the server. This will execute included init.lua which will compile the server code,
   configure WiFi, and start the server.

3. Want to serve your own files? Put them under the http/ folder and upload to the chip.
   For example, assuming you want to serve myfile.html, upload by typing:

         make upload FILE:=http/myfile.html

   Notice that while NodeMCU's filesystem does not support folders, filenames *can* contain slashes.
   We take advantage of that and only files that begin with "http/" will be accessible through the server.

3. Visit your server from a web browser.

   __Example:__ Say the IP for your ESP8266 is 2.2.2.2 and the server is
   running in the default port 80. Go to (http://2.2.2.2/index.html)[http://2.2.2.2/index.html] using your web browser.
   The ESP8266 will serve you with the contents of the file "http/index.html" (if it exists). If you visit the root (/)
   then index.html is served. By the way, unlike most HTTP servers, nodemcu_httpserver treats the URLs in a
   case-sensitive manner.

## HTTP Basic Authentication.

   It's supported. Turn it on in httpserver-conf.lua.

   Use it with care and don't fall into a false sense of security: HTTP Basic Authentication should not be
   considered secure since the server is not using encryption. Username and passwords travel
   in the clear.

## Server-side scripting using your own Lua scripts

   Yes, you can upload your own Lua scripts! This is pretty powerful.
   Just put it under http/ and upload it. Make sure it has a .lua extension.
   Your script should return a function that takes three parameters:

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

   This example assumes that you are using a [Wemos D1 Pro](https://wiki.wemos.cc/products:d1:d1_mini_pro)
   with two relay shields and two reed switches.
   The relays are controlled by the microcontroller and act as the push button,
   and can actually be connected in parallel with the existing mechanical button.
   The switches are wired so that the ESP8266 can tell whether the doors are open
   or closed at any given time.

#### Software description

   This example consists of the following files:

   * **garage_door.html**: Static HTML displays a form with all options for controlling the
   two garage doors.
   * **garage_door_control.html**: Looks like a garage door remote, how neat!
   * **garage_door_control.css**: Provides styling for garage_door_control.html.
   * **garage_door.lua**: Does the actual work. The script performs the desired action on
   the requested door and returns the results as JSON.
   * **apple-touch-icon.png**: This is optional. Provides an icon that
   will be used if you "Add to Home Screen" garage_door_control.html on an iPhone.
   Now it looks like an app!

#### Security implications

   Be careful permanently installing something like this in your home. The server provides
   no encryption. Your only layers of security are the WiFi network's password and simple
   HTTP authentication (if you enable it) which sends your password unencrypted.

   This script is provided for educational purposes. You've been warned.

## Not supported

* Other methods: HEAD, DELETE, TRACE, OPTIONS, CONNECT, PATCH
* Encryption / SSL
* Old nodemcu-firmware versions prior to January 2017) because I don't bother to test them.

## Contributing

   Since this is a project maintained in my free time, I am pretty lenient on contributions.
   I trust you to make sure you didn't break existing functionality nor the shipping examples
   and that you add examples for new features. I won't test all your changes myself but I
   am very grateful of improvements and fixes. Open issues in GitHub too, that's useful.

   Please keep your PRs focused on one thing. I don't mind lots of PRs. I mind PRs that fix multiple unrelated things.

   Follow the coding style as closely as possible:

   * No tabs, indent with 3 spaces
   * Unix (LF) line endings
   * Variables are camelCase
   * Follow file naming conventions
   * Use best judgement

## Notes on memory usage.

   The chip is very, very memory constrained.

   * Use a recent nodemcu-firmware. They've really improved memory usage and fixed leaks.
   * Use only the modules you need.
   * Use a firmware build without floating point support if you can.
   * Any help reducing the memory needs of the server without crippling its functionality is much appreciated!
   * Compile your Lua scripts in order to reduce their memory usage. The server knows to serve
   both .lua and .lc files as scripts.
