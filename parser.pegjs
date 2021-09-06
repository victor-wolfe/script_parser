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
comment = "//" comm:words { return {"type": "comment", "content": comm}; }
brackets = "[" code:code "]" { return {"type": "code", "code": code} }
choice = newChoice / oldChoice
nodebreak = "---" / nl
dialogue = char:character txt:words { return {"type": "dialogue", "character": char, "text": txt} }

// choice
newChoice = l:[A-Z] ")" _ t:words { return {"type":"choice", "choice": l, "text": t}}
oldChoice = "choice" "[" v:varName "]" b:oldChoiceBranches {return {"type":"choice", "choice": v, "branches": b} }
oldChoiceBranches = "[" v:varName "]:" _ t:words {return {"choice": v "text": t}}

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
code = setVar / jumplabel / goToLocation / ifStatement / achievement

setVar = "set" __ v:varName _ toEquals _ l:(literal / mathExp) {return `${v} = ${l}`}
	/ "set" __ v:varName _ o:operator _ n:number { return `${v} ${o}= ${n}`}
    / "set" __ v:varName d:doubleop { return `${v}${d}`}
toEquals = "to" / "="

jumplabel = "label" __ l:varName {return `Label: ${l}`}
    / "jump" __ l:varName {return `Jump to ${l}`}

goToLocation = teleportVerbs ( _ ":" / __ "to")? __ l:location {return `teleport to ${l.location}: ${l.state}`}
    / goToVerbs " to"? __ l:location {return `navigate to ${l}`}
goToVerbs =  "nav" / "navigate" / "goto" / "go"
teleportVerbs = "teleport" / "move" / "new location"
location = l:varName _ ":" _ s:varName {return {"location": l, "state":s}}
    / l:varName {return {"location": l, "state":"default"}}

ifStatement = i:("if" / "elseif" / "else if") __ e:exp __ c:code {return `${i} ${e} then ${c}`}
    / "else" __ c:code {return `else ${c}`}
exp = v:varName _ c:comparitor _ l:literal {return `${v} ${c} ${l}`}
    / v:varName _ c:comparitor _ vv:varName {return `${v} ${c} ${v}`}

achievement = "achievement" ":"? t:words {return `Achievement: ${t}`}

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

boolean = "true" {return true}
    / "false" {return false}
string = "\"" str:words "\"" {return str}
number = neg:"-"? num:digits { return neg ? parseInt(num, 10) * -1 : parseInt(num, 10)}

// keywords
commands =  "goto" / "go to" / "teleport" "to"? / "nav" "to"? / "navigate" "to"? / "continue" / "input" / "new" / "objective" / "complete"
comparitor = "==" / "equals" / "is" / "!=" / "isn't" / "<" / "lt" / "<=" / "lte" / ">" / "gt" / ">=" / "gte" / "&" / "and" / "|" / "or" 
operator = "+" / "-" / "/" / "*"
doubleop = "++" / "--"

// character groups
validVarChar = letter / digits / "_" / "-"
wordChar = letter / digits / punct
digits = d:[0-9]+ {return d.join("")}
unknownSpeaker = "???"

// single characters
punct = [….,-;!?—#$%&*<>/~+=()’] / "\"" / "\'"
letter = [a-zA-Z]

// whitespace
nl = [\n\r]

_ = [ \t]*

__ = [ \t]+