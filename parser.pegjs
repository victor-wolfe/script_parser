// const peg = require("peggy")

main = _ l:lines+ _ {return l}

lines = l:line nl? {return l}

line = nodebreak {return {"type":"nodeBreak"}}
	/ character nl
    / b:brackets 
	/ c:choice
	/ d:dialogue {return d}
    / w:words {return {"type": "narration", "text": w}}
    / comment

// top level categories
nodebreak = "---" / nl
comment = "//" comm:words { return {"type": "comment", "content": comm}; }
brackets = "[" code:code "]" { return {"type": "code", "code": code} }
choice = newChoice / choiceVar
dialogue = char:character txt:words { return {"type": "dialogue", "character": char, "text": txt} }

// choice
newChoice = l:[A-Z] ")" _ t:words { return {"type":"choice", "choice": l, "text": t} }
choiceVar = "choice"i __ v:varName ":"? {return {"type":"choice", "choice":v}}

// words for dialogue
words = _ w:(word _)+ { return w.flat().join("")}
word = l:wordChar+ {return l.join("")}
	/ inline

// names of characters
character = n:name ":" _ { return {"name":n} }
	/ n:name _ "[" c:varName "]" ":"? _ { return {"name": n, "emotion":c} }
name = mrName
	/ varName
    / unknownSpeaker
mrName = mr:varName ". " n:varName {return `${mr}. ${n}` }


// code 
code = setVar / jumplabel / goToLocation / ifStatement / achievement / continue / choiceVar / showImage / newObjective

setVar = "set"i __ v:varName _ toEquals _ l:(literal / mathExp) {return `${v} = ${l}`}
	/ "set"i __ v:varName _ o:operator _ n:number { return `${v} ${o}= ${n}`}
    / "set"i __ v:varName d:doubleop { return `${v}${d}`}
toEquals = "to"i / "="

jumplabel = "label"i __ l:varName {return `Label: ${l}`}
    / "jump"i __ l:varName {return `Jump to ${l}`}

goToLocation = teleportVerbs ( _ ":" / __ "to")? __ l:location {return `teleport to ${l.location}: ${l.state}`}
    / goToVerbs " to"i? __ l:location {return `navigate to ${l}`}
goToVerbs =  "nav"i / "navigate"i / "goto"i / "go"i
teleportVerbs = "teleport"i / "move"i / "new location"i
location = l:varName _ ":" _ s:varName {return {"location": l, "state":s}}
    / l:varName {return {"location": l, "state":"default"}}

ifStatement = i:ifElse __ e:exp __ c:code {return `${i} ${e} then ${c}`}
    / "else"i _ c:code? {return `else ${c}`}
    / i:ifElse __ "choice"i? v:varName " was chosen"i {return `${i} ${v} branch was chosen`}
ifElse = i:("if"i / "elseif"i / "else if"i)
exp = v:varName _ c:comparitor _ l:literal {return `${v} ${c} ${l}`}
    / v:varName _ c:comparitor _ vv:varName {return `${v} ${c} ${v}`}

achievement = "achievement"i ":"? t:words {return `Achievement: ${t}`}

continue = "continue"i / "then"i / "next"i

showImage = "show"i __ cg __ i:varName {return {"type":"image", "image":i}}
cg = "cg"i / "image"i / "illustration"i

newObjective = "new"i __ "objective"i _ ":"? t:words {return {"type":"objective", "status":"new", "text":t}}
    / "complete"i __ "objective"i _ ":"? t:words {return {"type":"objective", "status":"completed", "text":t}}

// arithmetic 
mathExp = head:term tail:(_ ("+" / "-") _ term)* {
    return tail.reduce(function(result, element) {
    if (element[1] === "+") { return result + element[3]; }
    if (element[1] === "-") { return result - element[3]; }
    }, head);
}

term = head:factor tail:(_ ("*" / "/") _ factor)* {
    return tail.reduce(function(result, element) {
    if (element[1] === "*") { return result * element[3]; }
    if (element[1] === "/") { return result / element[3]; }
    }, head);
}

factor = "(" _ expr:mathExp _ ")" { return expr; }
    / number


// variables 
inline = "@" v:varName "@" {return v}
varName = v:validVarChar+ {return v.join("")}

// literals
literal = string / boolean / number

boolean = "true"i {return true}
    / "false"i {return false}
string = "\"" str:words "\"" {return str}
number = neg:"-"? num:digits { return neg ? parseInt(num, 10) * -1 : parseInt(num, 10)}

// keywords
commands =   "input" / "new" / "objective" / "complete"
comparitor = "==" / "equals" / "is" / "!=" / "isn't" / "<" / "lt" / "<=" / "lte" / ">" / "gt" / ">=" / "gte" / "&" / "and" / "|" / "or" 
operator = "+" / "-" / "/" / "*"
doubleop = "++" / "--"

// character groups
validVarChar = letter / digits / "_" / "-"
wordChar = letter / digits / punct
digits = d:[0-9]+ {return d.join("")}
unknownSpeaker = "???"

// single characters
punct = [….,-;!?—#$%&*<>/~+=()’‘“”] / "\"" / "\'"
letter = [a-zA-Z]

// whitespace
nl = [\n\r]

_ = [ \t]*

__ = [ \t]+