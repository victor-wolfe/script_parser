const peg = require("peggy")

main = sp? l:(line nl?)+ sp? {return l}

nl = "\n"

line = nodebreak {return {"type":"nodeBreak"}}
	/ b:brackets 
	/ d:dialogue {return d}
    / w:words {return {"type": "narration", "text": w}}
    / comment


comment = "//" comm:words { return {"type": "comment", "content": comm}; }

brackets = "[" code:words "]" { return {"type": "code", "code": code} }

nodebreak = "---"

dialogue = char:character txt:words { return {"type": "dialogue", "character": char, "text": txt} }
character = n:word ":" sp? { return {"name":n} }
	/ n:word sp? "[" c:words "]" ":" sp? { return {"name": n, "emotion":c} }
words = w:(word " "?)+ { return w.flat().join("")}
word = l:letter+ {return l.join("")}
	/ inline
letter = [a-zA-Z0-9.!?-]

inline = "@" v:word "@" {return v}
sp = " "+