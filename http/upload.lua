return function (connection, req, args)
    dofile("httpserver-header.lc")(connection, 200, 'json')
	connection:send('{')

	local mbOffset = nil
	local mbLen = nil
	local mbData = nil
	local mbCmd = nil
	local mbFilename = nil
	local fieldsCount = 0
	local fileSize = 0
	local i = 0
	local binaryData = ''
	local currentByte = nil
	
    for name, value in pairs(args) do
        if (name == "offset") then
			mbOffset = tonumber(value, 10)

			fieldsCount = fieldsCount + 1
		end
		if (name == "len") then
			mbLen = tonumber(value, 10)
			
			fieldsCount = fieldsCount + 1
		end
		if (name == "data") then
			mbData = value
			
			fieldsCount = fieldsCount + 1
		end
		if (name == "filename") then
			mbFilename = value
			
			fieldsCount = fieldsCount + 1
		end
		if (name == "filesize") then
			fileSize = tonumber(value, 10)
			
			fieldsCount = fieldsCount + 1
		end
		if (name == "cmd") then
			mbCmd = value
			
			fieldsCount = fieldsCount + 1
		end
    end
	
	if (mbCmd == 'upload') then
		if (fieldsCount > 5) then
			if (mbFilename ~= 'http/upload.lua') then
				connection:send('"offset":"' .. mbOffset .. '",')
				connection:send('"len":"' .. mbLen .. '",')
				connection:send('"filename":"' .. mbFilename .. '"')

				for i=1,string.len(mbData),2 do
					currentByte = tonumber(string.sub(mbData, i, i + 1), 16)
					binaryData = binaryData .. string.char(currentByte)
				end

            local mbTmpFilename = string.sub(mbFilename, 0, 27) .. '.dnl' 
				if (mbOffset > 0) then
					file.open(mbTmpFilename,'a+')
				else
					file.remove(mbTmpFilename)					
					file.open(mbTmpFilename,'w+')
				end
				file.seek("set", mbOffset)
				file.write(binaryData)				
				file.close()
				
				binaryData = nil
				
				if (fileSize == mbLen + mbOffset) then
					file.remove(mbFilename)					
					file.rename(mbTmpFilename, mbFilename)
					file.remove(mbTmpFilename)						

					if (string.sub(mbFilename, -4) == '.lua') then
						file.remove(string.sub(mbFilename, 0, -3) .. "lc")
						node.compile(mbFilename)
						file.remove(mbFilename)
					end
				end		
			end
		end
	elseif (mbCmd == 'list') then
		local remaining, used, total=file.fsinfo()

		local headerExist = 0

		connection:send('"files":{')

		for name, size in pairs(file.list()) do
         if (headerExist > 0) then 
            connection:send(',')
         end

         local url = string.match(name, ".*/(.*)")
         url = name
         connection:send('"' .. url .. '":"' .. size .. '"')

         headerExist = 1
		end

		connection:send('},')

		connection:send('"total":"' .. total .. '",')
		connection:send('"used":"' .. used .. '",')
		connection:send('"free":"' .. remaining .. '"')
	elseif (mbCmd == 'remove') then
		if (fieldsCount > 1) then
			if (mbFilename ~= 'http/upload.lua') and (mbFilename ~= 'http/upload.lc') and (mbFilename ~= 'http/upload.html.gz') then
				file.remove(mbFilename)
			end
		end
	end

	connection:send('}')	
	collectgarbage()
end
