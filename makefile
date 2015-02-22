
######################################################################
# User configuration
######################################################################
# Path to the tool and serial port
LUATOOL=../luatool/luatool/luatool.py
PORT=/dev/cu.usbserial-A602HRAZ

######################################################################
# End of user config
######################################################################
HTTP_FILES := $(wildcard http/*)
LUA_FILES := init.lua httpserver.lua

# Print usage
usage:
	@echo "make upload_http      to upload http files only"
	@echo "make upload_lua       to upload init.lua and httpserver.lua"
	@echo "make upload           to upload all"

# Upload HTTP files only
upload_http: $(HTTP_FILES)
	$(foreach f, $^, $(LUATOOL) -f $(f) -t $(f) -p $(PORT);)

# Upload httpserver lua files (init and server module)
upload_lua: $(LUA_FILES)
	$(foreach f, $^, $(LUATOOL) -f $(f) -t $(f) -p $(PORT);)

# Upload all
upload: upload_http upload_lua

