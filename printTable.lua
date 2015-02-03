-- Print anything - including nested tables
-- Based on but modified from:
-- http://lua-users.org/wiki/TableSerialization
function printTable (tt, indent, done)
   done = done or {}
   indent = indent or 0
   if tt == nil then
      io.write("nil\n")
   else
      if type(tt) == "table" then
         for key, value in pairs (tt) do
            io.write(string.rep (" ", indent)) -- indent it
            if type (value) == "table" and not done [value] then
               done [value] = true
               io.write(string.format("[%s] => table\n", tostring (key)));
               io.write(string.rep (" ", indent+4)) -- indent it
               io.write("(\n");
               table_print (value, indent + 7, done)
               io.write(string.rep (" ", indent+4)) -- indent it
               io.write(")\n");
            else
               io.write(string.format("[%s] => %s\n",
               tostring (key), tostring(value)))
            end
         end
      else
         io.write(tt .. "\n")
      end
   end
end
