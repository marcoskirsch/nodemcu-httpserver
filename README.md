# nodemcu-httpserver
A (very) simple web server written in Lua for the ESP8266 firmware NodeMCU.

## Features

* GET
* Multiple MIME types
* Error pages (404 and others)
* Server-side execution of Lua scripts
* Query string argument parsing

## How to use

1. Upload server files using [luatool.py](https://github.com/4refr0nt/luatool) or equivalent.
   Or, even better, use GNU Make with the bundled makefile. Type the following to upload
   server code, init.lua (which you may want to modify), and some example files.

         make upload

   Compile the server files so that it uses less memory. This needs free memory so I suggest
   you do it after a fresh node.restart().

         node.compile("httpserver.lua")
         node.compile("httpserver-static.lua")
         node.compile("httpserver-error.lua")

   If this is not in init.lua, then start the server by typing:

         dofile("httpserver.lc")(80)

   In this example, 80 is the port your server is listening at but you can change it.

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

   If you are going to be sending lots (as in over a KB) of data, you should yield the thread/coroutine every now and then
   in order to avoid overflowing the buffer in the microcontroller. Use:

      coroutine.yield()

   Look at the included example scripts for more ideas.


## Not supported

* Other methods: HEAD, POST, PUT, DELETE, TRACE, OPTIONS, CONNECT, PATCH
* HTTP authentication
* Encryption

## Open issues

* File system doesn't like long names, need to protect:

        PANIC: unprotected error in call to Lua API (httpserver.lua:78: filename too long)

* nodemcu firmware with floating point doesn't have enough memory to compile nor run the server. See below.

* luatool.py which is used by the makefile, doesn't support uploading binary files (yet?).
  But I've successfully used [nodemcu-uploader](https://github.com/kmpm/nodemcu-uploader). The only
  thing to know is that after uploading a file, you need to file.rename() it to add the http/ prefix.

## Notes on memory usage.

   The chip is very, very memory constrained. You must use a recent build of nodemcu-firmware that supports
   node.compile() since the server expects the helper scripts to be compiled.

   * If you can't compile the server code without error even after a fresh restart, then you may need a build
     of the firmware without floating point. In file nodemcu-firmware/app/lua/luaconf.h right around line 572 (line number
     may change in the future) add

         #define LUA_NUMBER_INTEGRAL

     Then rebuild and re-flash the firmware.

   * Any help reducing the memory needs of the server without crippling its features are appreciated!
