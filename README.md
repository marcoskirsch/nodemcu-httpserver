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

## Not supported

* Other methods: HEAD, POST, PUT, DELETE, TRACE, OPTIONS, CONNECT, PATCH
* Server side scripting.

## Open issues
