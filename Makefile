######################################################################
# User configuration
######################################################################
# Path to nodemcu-uploader (https://github.com/kmpm/nodemcu-uploader)
NODEMCU-UPLOADER=nodemcu-uploader.py
# Serial port
PORT=/dev/ttyUSB0
SPEED=460800

######################################################################
# End of user config
######################################################################
HTTP_FILES := $(wildcard http/*)
LUA_FILES := init.lua httpserver.lua httpserver-request.lua httpserver-static.lua httpserver-error.lua

# Print usage
usage:
	@echo "make upload_http      to upload files to be served"
	@echo "make upload_server    to upload the server code and init.lua"
	@echo "make upload           to upload all"

# Upload HTTP files only
upload_http: $(HTTP_FILES)
	@$(NODEMCU-UPLOADER) -b $(SPEED) -p $(PORT) upload $(foreach f, $^, $(f))

# Upload httpserver lua files (init and server module)
upload_server: $(LUA_FILES)
	@$(NODEMCU-UPLOADER) -b $(SPEED) -p $(PORT) upload $(foreach f, $^, $(f))

# Upload all
upload: $(LUA_FILES) $(HTTP_FILES)
	@$(NODEMCU-UPLOADER) -b $(SPEED) -p $(PORT) upload $(foreach f, $^, $(f))

#test
test:  $(LUA_FILES) $(HTTP_FILES)
	echo -b $(SPEED) -p $(PORT) upload $(foreach f, $^, -f $(f) -d $(f))
