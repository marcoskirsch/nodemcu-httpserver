# nodemcu-httpserver
A (very) simple web server written in Lua for the ESP8266 firmware NodeMCU.

## Features

* GET
* Multiple MIME types
* Error pages (404 and others)
* Remote execution of Lua scripts
* Query string argument parsing

## How to use

1. Upload server files using [luatool.py](https://github.com/4refr0nt/luatool) or equivalent.
   Or, even better, use GNU Make with the bundled makefile. Type the following to upload
   server, init, and some example files.

         make upload

   Add the following to your init.lua in order to start the server:

         require("httpserver")
         server = httpserver.start(80, 10)

   In this example, 80 is the port your server is listening to, and 10 is the timeout (in seconds) for clients.

2. Upload files you want to serve.
   Again, use luatool.py or similar and upload the HTML and other files.

   All the files you upload must be prefixed with "http/". Wait, what?

   Yes: NodeMCU's filesystem does not support folders, but filenames *can* contain slashes.
   Only files that begin with "http/" will be accessible through the server.

3. Visit your server from a web browser.

   __Example:__ Say the IP for your ESP8266 is 2.2.2.2 and the server is
   running in the default port 80. Go to http://2.2.2.2/index.html using your web browser. The ESP8266 will serve you with the contents
   of the file "http/myPage.html" (if it exists). If you visit the root (/)
   then index.html is served. By the way, unlike some http servers, the URLs are case-sensitive.

## How to create dynamic Lua scripts

   Similar to static files, upload a Lua script called "http/[name].lua where you replace [name] with the script's name.
   The script should return a function that takes two parameters:

      return function (connection, args)
         -- code goes here
      end

   Use the _connection_ parameter to send the response back to the client. Note that you are in charge of sending the HTTP header.
   The _args_ parameter is a Lua table that contains any arguments sent by the client in the GET request.

   For example, if the client requests _http://2.2.2.2/foo.lua?color=red_ then the server will execute the function
   in your Lua script _foo.lua_ and pass in _connection_ and _args_, where _args.color == "red"_.

   The easiest is to look at some of the included example scripts.

## Not supported

* Other methods: HEAD, POST, PUT, DELETE, TRACE, OPTIONS, CONNECT, PATCH
* HTTP authentication
* Encryption

## Open issues

* File system doesn't like long names, need to protect:

        PANIC: unprotected error in call to Lua API (httpserver.lua:78: filename too long)

* nodemcu firmware with floating point doesn't have enough memory to compile nor run the server. See below.

* Binary files haven't been tested yet since luatool.py doesn't support uploading anything but text files.
  If anyone has any luck with this, let us know!

## A note on memory usage.

   The chip is very, very memory constrained. If you find yourself having trouble running the server or anything beyond the most trivial scripts,
   then try some of the following:

   * Use a recent build of nodemcu-firmware that supports node.compile().
     Compiled Lua code has extension .lc and has smaller memory footprint.
     After uploading the server code (httpserver.lua) but before running anything,
     type:

         node.compile("httpserver.lua")

   * If you can't even compile the server code, then you may need a build of the firmware without
     floating point. In file nodemcu-firmware/app/lua/luaconf.h right around line 572 (line number
     may change in the future) add

         #define LUA_NUMBER_INTEGRAL

     Then rebuild and re-flash the firmware. But if you **must** have floating point numbers and
     run this server code, you may be out of luck.

   * Any help reducing the memory needs of the server without crippling its features are appreciated!
