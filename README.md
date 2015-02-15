# nodemcu-httpserver
A (very) simple web server written in Lua for the ESP8266 firmware NodeMCU.

## Features

* **GET**
* **Multiple MIME types**
* **Error pages (404 and others)**

## How to use

1. Upload httpserver.lua using [luatool.py](https://github.com/4refr0nt/luatool) or equivalent.
   Add the following to your init.lua in order to start the server:

         require("httpserver")
         server = httpserver.start(80, 10)

   80 is the port your server is listening to, and 10 is the timeout (in seconds) for clients.

2. Upload the files you want to serve.
   Again, use luatool.py or similar and upload the HTML and other files.

   All the files you upload must be prefixed with "http/". Wait, what?

   Yes: NodeMCU's filesystem does not support folders, but filenames *can* contain slashes.

3. Visit your server from a web browser.

   __Example:__ Say the IP for your ESP8266 is 2.2.2.2 and the server is
   running in the default port 80. Go to http://2.2.2.2/index.html using your web browser. The ESP8266 will serve you with the contents
   of the file "http/myPage.html" (if it exists). If you visit the root (/)
   then index.html is server. By the way, the URLs are case-sensitive.

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

## Not supported

* Other methods: HEAD, POST, PUT, DELETE, TRACE, OPTIONS, CONNECT, PATCH
* Server side scripting.

## Open issues
* File system doesn't like long names, need to protect:

        PANIC: unprotected error in call to Lua API (httpserver.lua:78: filename too long)
