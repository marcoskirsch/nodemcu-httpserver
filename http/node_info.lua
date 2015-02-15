local function sendHeader(connection)
   connection:send("HTTP/1.0 200 OK\r\nContent-Type: text/html\r\Cache-Control: private, no-store\r\n\r\n")
end

local function sendAttr(connection, attr, val)
   connection:send("<li><b>".. attr .. ":</b> " .. val .. "<br></li>\n")
end

return function (connection, args)
   collectgarbage()
   sendHeader(connection)
   connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>A Lua script sample</title></head>')
   connection:send('<body>')
   connection:send('<h1>Node info</h1>')
   majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info();
   connection:send('<ul>Node info:')
   sendAttr(connection, "majorVer"     , majorVer)
   sendAttr(connection, "devVer"       , devVer)
   sendAttr(connection, "chipid"       , chipid)
   sendAttr(connection, "flashid"      , flashid)
   sendAttr(connection, "flashsize"    , flashsize)
   sendAttr(connection, "flashmode"    , flashmode)
   sendAttr(connection, "flashspeed"   , flashspeed)
   sendAttr(connection, "node.heap()"  , node.heap())
   connection:send('</ul>')
   connection:send('</body></html>')
end
