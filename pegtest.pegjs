const peg = require("peggy")

main = ws? l:(line nl?)+ ws? {return l}

nl = "\n"

line = nodebreak {return {"type":"nodeBreak"}}
	/ b:brackets 
	/ c:choice
	/ d:dialogue {return d}
    / w:words {return {"type": "narration", "text": w}}
    / comment


comment = "//" comm:words { return {"type": "comment", "content": comm}; }

brackets = "[" code:words "]" { return {"type": "code", "code": code} }

choice = l:[A-Z] ")" ws? t:words { return {"type":"choice", "choice": l, "text": t}}

nodebreak = "---"

dialogue = char:character txt:words { return {"type": "dialogue", "character": char, "text": txt} }
character = n:name ":" ws? { return {"name":n} }
	/ n:name ws? "[" c:words "]" ":" ws? { return {"name": n, "emotion":c} }
name = mrName
	/ word
words = ws? w:(word " "?)+ { return w.flat().join("")}
word = l:wordChar+ {return l.join("")}
	/ inline

inline = "@" v:variable "@" {return v}

variable = v:validVar+ {return v.join("")}
number = neg:"-"? num:digit+ {return (neg + num)} 

mrName = mr:validVar ". " n:validVar {return `${mr}. ${n}` }
validVar = letter / digit / "_" / "-"
wordChar = letter / digit / punct

punct = [.,-;!]
letter = [a-zA-Z]
digit = [0-9]
ws = "\t"+ / " "+ 
