# nodemcu-httpserver
A (very) simple web server written in Lua for the ESP8266 firmware NodeMCU.

## Features

* **GET**

   Simple GET method will return the requested file.
   NodeMCU's filesystem does not support folders, but filenames *can* contain slashes.
   So prefix your server files with "http/" (yeah, weird).

   __Example:__ Say the IP for your ESP8266 is 2.2.2.2 and the server is running in the default port 80.
   Go to http://2.2.2.2/index.html using your web browser. The ESP8266 will serve you with the contents
   of the file "http_index.html" (if it exists).

## Not supported

* Other methods: GET, HEAD, POST, PUT, DELETE, TRACE, OPTIONS, CONNECT, PATCH
* Serving anything that's not HTML (different mime types)
* Server side scripting.

## Open issues
