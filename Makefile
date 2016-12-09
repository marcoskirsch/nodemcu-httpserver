######################################################################
# User configuration
######################################################################
# Path to nodemcu-uploader (https://github.com/kmpm/nodemcu-uploader)
NODEMCU-UPLOADER=../nodemcu-uploader/nodemcu-uploader.py
# Serial port
PORT=/dev/cu.SLAB_USBtoUART
SPEED=9600

NODEMCU-COMMAND=$(NODEMCU-UPLOADER) -b $(SPEED) --start_baud $(SPEED) -p $(PORT) upload

######################################################################
# End of user config
######################################################################
HTTP_FILES := $(wildcard http/*)
LUA_FILES := \
   init.lua \
   httpserver.lua \
   httpserver-b64decode.lua \
   httpserver-basicauth.lua \
   httpserver-conf.lua \
   httpserver-connection.lua \
   httpserver-error.lua \
   httpserver-header.lua \
   httpserver-request.lua \
   httpserver-static.lua \

# Print usage
usage:
	@echo "make upload FILE:=<file>  to upload a specific file (i.e make upload FILE:=init.lua)"
	@echo "make upload_http          to upload files to be served"
	@echo "make upload_server        to upload the server code and init.lua"
	@echo "make upload_all           to upload all"
	@echo $(TEST)

# Upload one files only
upload:
	@python $(NODEMCU-COMMAND) $(FILE)

# Upload HTTP files only
upload_http: $(HTTP_FILES)
	@python $(NODEMCU-COMMAND) $(foreach f, $^, $(f))

# Upload httpserver lua files (init and server module)
upload_server: $(LUA_FILES)
	@python $(NODEMCU-COMMAND) $(foreach f, $^, $(f))

# Upload all
upload_all: $(LUA_FILES) $(HTTP_FILES)
	@python $(NODEMCU-COMMAND) $(foreach f, $^, $(f))

