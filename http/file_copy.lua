return function (connection, req, args)
   dofile('httpserver-header.lc')(connection, 200, 'html')

   connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Copy file</title></head><body><h1>Copy file</h1>')

   if req.method == 'GET' then
      connection:send('<form method="POST">From:<br><input type="text" name="from_file"><br>To:<br><input type="text" name="to_file"><br><input type="submit" name="submit" value="Submit"></form>')
   elseif req.method == 'POST' then
      local rd = req.getRequestData()
      collectgarbage()
      local blocksize = 1024
      file.open(rd['from_file'], 'r')
      local buffer = file.read(blocksize)
      file.close()
      file.open(rd['to_file'], 'w')
      file.write(buffer)
      file.close()
      buffer = nil
      collectgarbage()
      local offset = blocksize
      file.open(rd['from_file'], 'r')
      local from_file_offset = file.seek('set', offset)
      while not (from_file_offset == nil) do
         buffer = file.read(blocksize)
         file.close()
         file.open(rd['to_file'], 'a+')
         file.seek('end')
         file.write(buffer)
         file.close()
         buffer = nil
         collectgarbage()
         file.open(rd['from_file'], 'r')
         offset = offset + blocksize
         from_file_offset = file.seek('set', offset)
      end
      file.close()
      buffer = nil
      collectgarbage()
   end

   connection:send('</body></html>')
end
