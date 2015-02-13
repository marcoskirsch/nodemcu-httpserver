
######################################################################
# User configuration
######################################################################
# Path to the tool and serial port
LUATOOL=./luatool/luatool/luatool.py
PORT=/dev/ttyUSB0

######################################################################
# End of user config
######################################################################
HTTP_FILES := $(wildcard http/*html)

# Print usage
usage:
	@echo "make upload_http      to upload http files only"
	@echo "make upload_program   to upload init.lua and httpserver.lua"
	@echo "make upload           to upload all"

# Upload HTTP files only
upload_http: $(HTTP_FILES)
	$(foreach f, $^, $(LUATOOL) -f $(f) -t $(f) -p $(PORT);)

# Upload httpserver lua files (init and server module)
upload_program: init.lua httpserver.lua
	$(LUATOOL) -f init.lua -t init.lua -p $(PORT)

# Upload all
upload: upload_http upload_program

