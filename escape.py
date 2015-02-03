# esta es una prueba para modificar luatool.py
# http://stackoverflow.com/a/18935765/316875
from string import maketrans

def escapeString(a_string):
   translationTable = maketrans({"-":  r"\-", "]":  r"\]", "\\": r"\\", "^":  r"\^", "$":  r"\$", "*":  r"\*", ".":  r"\."})
   escaped = a_string.translate(translationTable)
   return escaped

print escapeString("Marcos")


#!/usr/bin/python
'''

intab = "aeiou"
outtab = "12345"
trantab = maketrans(intab, outtab)

str = "this is string example....wow!!!";
print str.translate(trantab);

'''
