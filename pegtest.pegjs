const peg = require("peggy")

main = ws? l:(line nl?)+ ws? {return l}

line = nodebreak {return {"type":"nodeBreak"}}
	/ b:brackets 
	/ c:choice
	/ d:dialogue {return d}
    / w:words {return {"type": "narration", "text": w}}
    / comment

// top level categories
comment = "//" comm:words { return {"type": "comment", "content": comm}; }
brackets = "[" code:code "]" { return {"type": "code", "code": code} }
choice = l:[A-Z] ")" ws? t:words { return {"type":"choice", "choice": l, "text": t}}
nodebreak = "---"
dialogue = char:character txt:words { return {"type": "dialogue", "character": char, "text": txt} }


// words for dialogue
words = ws? w:(word ws?)+ { return w.flat().join("")}
word = l:wordChar+ {return l.join("")}
	/ inline

// names of characters
character = n:name ":" ws? { return {"name":n} }
	/ n:name ws? "[" c:varName "]" ":" ws? { return {"name": n, "emotion":c} }
name = mrName
	/ varName
mrName = mr:varName ". " n:varName {return `${mr}. ${n}` }


// code 
code = setVar / jumplabel / goToLocation
setVar = "set" ws v:varName ws? toEquals ws? l:literal {return `${v} = ${l}`}
	/ "set" ws v:varName ws? o:operator ws? n:number { return `${v} ${o}= ${n}`}
    / "set" ws v:varName d:doubleop { return `${v}${d}`}
toEquals = "to" / "="
jumplabel = "label" ws l:varName {return `Label: ${l}`}
    / "jump" ws l:varName {return `Jump to ${l}`}
goToLocation = teleportVerbs " to"? ws l:location {return `teleport to ${l.location}: ${l.state}`}
    / goToVerbs " to"? ws l:location {return `navigate to ${l}`}
goToVerbs =  "nav" / "navigate" / "goto" / "go"
teleportVerbs = "teleport" / "move"
location = l:varName ws? ":" ws? s:varName {return {"location": l, "state":s}}
    / v:varName {return {"location": l, "state":"default"}}

// variables 
inline = "@" v:varName "@" {return v}
varName = v:validVarChar+ {return v.join("")}

// literals
literal = string / boolean / number

boolean = "true" {return true}
    / "false" {return false}
string = "\"" str:words "\"" {return str}
number = neg:"-"? num:digits { return neg ? parseInt(num, 10) * -1 : parseInt(num, 10)}

// keywords
ifelse = "if" / "elseif" / "else if" / "else"
commands =  "goto" / "go to" / "teleport" "to"? / "nav" "to"? / "navigate" "to"? / "continue" / "input" / "new" / "objective" / "complete"
comparitors = "==" / "equals" / "is" / "!=" / "isn't" / "<" / "lt" / "<=" / "lte" / ">" / "gt" / ">=" / "gte" / "&" / "and" / "|" / "or" 
operator = "+" / "-" / "/" / "*"
doubleop = "++" / "--"

// character groups
validVarChar = letter / digits / "_" / "-"
wordChar = letter / digits / punct
digits = d:[0-9]+ {return d.join("")}

// single characters
punct = [.,-;!—#$%&*<>/~+=()]
letter = [a-zA-Z]

// whitespace
ws = "\t"+ / " "+ 
nl = "\n"