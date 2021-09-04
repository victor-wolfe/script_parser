const peg = require("peggy")
const parser = peg.generate("start = ('a' / 'b')+");

textWorks 
  = "wc:" space* wc:wordCount { return wc; }
  / "lc:" space* lc:letterCount { return lc; }

wwordCounter = w:(word space?)*  { return w.length; }
word = letter+
letter = [a-zA-Z0-9]
space = " "