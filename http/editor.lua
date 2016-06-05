return function (connection, req, args)
   dofile('httpserver-header.lc')(connection, 200, 'html')

   if req.user == nil then
      --print("prompt not authenticated")
      connection:send([===[
<h1>This Page only for authenticated user</h1>
<p>Please enable authentication in "httpserver-conf.lua".</p>
]===])
   elseif req.method == 'POST' then
      --print('POST method')
      local rd = req.getRequestData()
      print(node.heap())
      collectgarbage()
      print(node.heap())
      if rd['action'] == 'load' then
         --print('load')
         file.open('http/' .. rd['filename'], 'r')
         local buffer = file.read()
         while buffer ~= nil do
            connection:send(buffer)
            buffer = file.read()
         end
         file.close()
      elseif rd['action'] == 'save' then
         --print('save')
         local data = rd['data']
         file.open('http/' .. rd['filename'], 'w+')
         file.write(data)
         file.close()
         connection:send('initial write: ' .. string.len(data))
      elseif rd['action'] == 'append' then
         --print('append')
         local data = rd['data']
         file.open('http/' .. rd['filename'], 'a+')
         file.seek('end')
         file.write(data)
         file.close()
         connection:send('append: ' .. string.len(data))
      elseif rd['action'] == 'compile' then
         --print('compile')
         node.compile('http/' .. rd['filename'])
         connection:send('<a href=\"' .. edit_filename .. '.lc\">' .. edit_filename .. '.lc</a>')
      end
   end
   collectgarbage()
end
