local function sendAttr(connection, attr, val, unit)
   --Avoid error when Nil is in atrib=val pair.
   if not attr or not val then
      return
   else
      if unit then
         unit = ' ' .. unit
   else
      unit = ''
   end
      connection:send("<li><b>".. attr .. ":</b> " .. val .. unit .. "<br></li>\n")
   end
end

return function (connection, req, args)
   dofile("httpserver-header.lc")(connection, 200, 'html')
   connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>A Lua script sample</title></head><body><h1>Node info</h1><ul>')
   majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info();
   sendAttr(connection, "NodeMCU version"       , majorVer.."."..minorVer.."."..devVer)
   sendAttr(connection, "chipid"                , chipid)
   sendAttr(connection, "flashid"               , flashid)
   sendAttr(connection, "flashsize"             , flashsize, 'Kb')
   sendAttr(connection, "flashmode"             , flashmode)
   sendAttr(connection, "flashspeed"            , flashspeed / 1000000 , 'MHz')
   sendAttr(connection, "heap free"             , node.heap() , 'bytes')
   sendAttr(connection, 'Memory in use'         , collectgarbage("count") , 'KB')
   ip, subnetMask = wifi.sta.getip()
   sendAttr(connection, 'Station IP address'    , ip)
   sendAttr(connection, 'Station subnet mask'   , subnetMask)
   sendAttr(connection, 'MAC address'           , wifi.sta.getmac())
   sendAttr(connection, 'Auth user'             , req.user)
   connection:send('</ul></body></html>')
end
