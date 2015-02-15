local function sendHeader(connection)
   connection:send("HTTP/1.0 200 OK\r\nContent-Type: text/html\r\Cache-Control: private, no-store\r\n\r\n")
end

return function (connection, args)
   sendHeader(connection)
   connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>A Lua script sample</title></head>')
   connection:send('<body>')
   connection:send('<h1>Memory Statistics</h1>')
   connection:send('Heap: ' .. node.heap() .. ' bytes')
   connection:send('Garbage collector use: ' .. collectgarbage("count") .. ' kilobytes')
   connection:send('</body></html>')
end
