-- Print anything - including nested tables
-- Based on but modified from:
-- http://lua-users.org/wiki/TableSerialization
module("TablePrinter", package.seeall)

function TablePrinter.print (tt, indent, done)
   done = done or {}
   indent = indent or 0
   if tt == nil then
      print("nil\n")
   else
      if type(tt) == "table" then
         for key, value in pairs (tt) do
            print(string.rep (" ", indent)) -- indent it
            if type (value) == "table" and not done [value] then
               done [value] = true
               print(string.format("[%s] => table\n", tostring (key)));
               print(string.rep (" ", indent+4)) -- indent it
               print("(\n");
               table_print (value, indent + 7, done)
               print(string.rep (" ", indent+4)) -- indent it
               print(")\n");
            else
               print(string.format("[%s] => %s\n",
               tostring (key), tostring(value)))
            end
         end
      else
         print(tt .. "\n")
      end
   end
end
