######################################################################
# Makefile user configuration
######################################################################

# Path to nodemcu-uploader (https://github.com/kmpm/nodemcu-uploader)
NODEMCU-UPLOADER?=python ../nodemcu-uploader/nodemcu-uploader.py

# Path to LUA cross compiler (part of the nodemcu firmware; only needed to compile the LFS image yourself)
LUACC?=../nodemcu-firmware/luac.cross

# Serial port
PORT?=$(shell ls /dev/cu.SLAB_USBtoUART /dev/ttyUSB* 2>/dev/null|head -n1)
SPEED?=115200

define _upload
@$(NODEMCU-UPLOADER) -b $(SPEED) --start_baud $(SPEED) -p $(PORT) upload $^
endef

######################################################################

LFS_IMAGE ?= lfs.img
HTTP_FILES := $(wildcard http/*)
WIFI_CONFIG := $(wildcard *conf*.lua)
SERVER_FILES := $(filter-out $(WIFI_CONFIG), $(wildcard srv/*.lua) $(wildcard *.lua))
LFS_FILES := $(LFS_IMAGE) $(filter-out $(WIFI_CONFIG), $(wildcard *.lua))
FILE ?=

# Print usage
usage:
	@echo "make upload FILE:=<file>  to upload a specific file (i.e make upload FILE:=init.lua)"
	@echo "make upload_http          to upload files to be served"
	@echo "make upload_server        to upload the server code and init.lua"
	@echo "make upload_all           to upload all"
	@echo "make upload_lfs           to upload lfs based server code"
	@echo "make upload_all_lfs       to upload all (LFS based)"

# Upload one file only
upload: $(FILE)
	$(_upload)

# Upload HTTP files only
upload_http: $(HTTP_FILES)
	$(_upload)

# Upload httpserver lua files
upload_server: $(SERVER_FILES)
	$(_upload)

# Upload wifi configuration
upload_wifi_config: $(WIFI_CONFIG)
	$(_upload)

# Upload lfs image
upload_lfs: $(LFS_FILES)
	$(_upload)

$(LFS_IMAGE):
	$(LUACC) -f -o $(LFS_IMAGE) srv/*.lua

# Upload all non-lfs files
upload_all: $(HTTP_FILES) $(SERVER_FILES) $(WIFI_CONFIG)
	$(_upload)

# Upload all lfs files
upload_all_lfs: $(HTTP_FILES) $(LFS_FILES) $(WIFI_CONFIG)
	$(_upload)

.ENTRY: usage
.PHONY: usage upload_http upload_server upload_wifi_config \
upload_lfs upload_all upload_all_lfs
