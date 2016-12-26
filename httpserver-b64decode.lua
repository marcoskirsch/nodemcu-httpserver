#!/usr/local/bin/lua
-- httpserver-b64decode.lua
-- Part of nodemcu-httpserver, contains b64 decoding used for HTTP Basic Authentication.
-- Modified to use an exponentiation by multiplication method for only applicable for unsigned integers.
-- Based on http://lua-users.org/wiki/BaseSixtyFour by Alex Kloss
-- compatible with lua 5.1
-- http://www.it-rfc.de
-- Author: Marcos Kirsch

local function uipow(a, b)
    local ret = 1
    if b >= 0 then
        for i = 1, b do
            ret = ret * a
        end
    end
    return ret
end

-- bitshift functions (<<, >> equivalent)
-- shift left
local function lsh(value,shift)
   return (value*(uipow(2, shift))) % 256
end

-- shift right
local function rsh(value,shift)
   -- Lua builds with no floating point don't define math.
   if math then return math.floor(value/uipow(2, shift)) % 256 end
   return (value/uipow(2, shift)) % 256
end

-- return single bit (for OR)
local function bit(x,b)
   return (x % uipow(2, b) - x % uipow(2, (b-1)) > 0)
end

-- logic OR for number values
local function lor(x,y)
   result = 0
   for p=1,8 do result = result + (((bit(x,p) or bit(y,p)) == true) and uipow(2, (p-1)) or 0) end
   return result
end

-- Character decoding table
local function toBase64Byte(char)
   ascii = string.byte(char, 1)
   if ascii >= string.byte('A', 1) and ascii <= string.byte('Z', 1) then return ascii - string.byte('A', 1)
   elseif ascii >= string.byte('a', 1) and ascii <= string.byte('z', 1) then return ascii - string.byte('a', 1) + 26
   elseif ascii >= string.byte('0', 1) and ascii <= string.byte('9', 1) then return ascii + 4
   elseif ascii == string.byte('-', 1) then return 62
   elseif ascii == string.byte('_', 1) then return 63
   elseif ascii == string.byte('=', 1) then return nil
   else return nil, "ERROR! Char is invalid for Base64 encoding: "..char end
end


-- decode base64 input to string
return function(data)
   local chars = {}
   local result=""
   for dpos=0,string.len(data)-1,4 do
      for char=1,4 do chars[char] = toBase64Byte((string.sub(data,(dpos+char),(dpos+char)) or "=")) end
         result = string.format(
         '%s%s%s%s',
         result,
         string.char(lor(lsh(chars[1],2), rsh(chars[2],4))),
         (chars[3] ~= nil) and string.char(lor(lsh(chars[2],4),
         rsh(chars[3],2))) or "",
         (chars[4] ~= nil) and string.char(lor(lsh(chars[3],6) % 192,
         (chars[4]))) or ""
      )
   end
   return result
end
