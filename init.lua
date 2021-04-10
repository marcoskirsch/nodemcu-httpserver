-- check/flash/use LFS support, if possible
if node.getpartitiontable().lfs_size > 0 then
   if file.exists("lfs.img") then
      if file.exists("lfs_lock") then
	 file.remove("lfs_lock")
	 file.remove("lfs.img")
      else
	 local f = file.open("lfs_lock", "w")
	 f:flush()
	 f:close()
	 file.remove("httpserver-compile.lua")
	 node.LFS.reload("lfs.img")
      end
   end
   pcall(node.flashindex("_init"))
end

-- Compile freshly uploaded nodemcu-httpserver lua files.
if file.exists("httpserver-compile.lua") then
   dofile("httpserver-compile.lua")
   file.remove("httpserver-compile.lua")
end


-- Set up NodeMCU's WiFi
dofile("httpserver-wifi.lc")

-- Start nodemcu-httpsertver
dofile("httpserver-init.lc")
