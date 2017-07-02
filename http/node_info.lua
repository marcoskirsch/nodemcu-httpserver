local function sendAttr(connection, attr, val)
   --Avoid error when Nil is in atrib=val pair.
   if not attr or not val then
      return
   else
      connection:send("<li><b>".. attr .. ":</b> " .. val .. "<br></li>\n")
   end
end

return function (connection, req, args)
   dofile("httpserver-header.lc")(connection, 200, 'html')
   connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>A Lua script sample</title></head><body><h1>Node info</h1><ul>')
   majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info();
   sendAttr(connection, "NodeMCU version"       , majorVer.."."..minorVer.."."..devVer)
   sendAttr(connection, "chipid"                , chipid)
   sendAttr(connection, "flashid"               , flashid)
   sendAttr(connection, "flashsize (KB)"        , flashsize)
   sendAttr(connection, "flashmode"             , flashmode)
   sendAttr(connection, "flashspeed (MHz)"      , flashspeed / 1000000)
   sendAttr(connection, "heap free (bytes)"     , node.heap())
   sendAttr(connection, 'Memory in use (KB)'    , collectgarbage("count"))
   sendAttr(connection, 'Station IP address'    , wifi.sta.getip())
   sendAttr(connection, 'MAC address'           , wifi.sta.getmac())
   connection:send('</ul></body></html>')
end
