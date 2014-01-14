module lang::missgrant::base::CompileAST

import lang::java::jdt::m3::AST;
import analysis::m3::AST; 
import lang::missgrant::base::AST;

Expression IOException = qualifiedName(qualifiedName(simpleName("java"), simpleName("io")), simpleName("IOException"));
Expression Scanner = qualifiedName(qualifiedName(simpleName("java"), simpleName("util")), simpleName("Scanner"));
Expression PrintWriter = qualifiedName(qualifiedName(simpleName("java"), simpleName("io")), simpleName("PrintWriter"));
Expression Writer = qualifiedName(qualifiedName(simpleName("java"), simpleName("io")), simpleName("Writer"));

    
Declaration compile(str name, Controller ctl) =
     compilationUnit([], [class(name, [], [], [
       method(\void(), "main", [parameter(arrayType(simpleType(simpleName("String"))) , "args", 0)], [],
         expressionStatement(methodCall(false, newObject(simpleType(simpleName(name)), []) , "run", [
            newObject(simpleType(Scanner), [fieldAccess(false, simpleName("System"), "in")]),
            newObject(simpleType(PrintWriter), [fieldAccess(false, simpleName("System"), "out")])]))
       )[@modifiers=[\public(), \static()]],
       *state2consts(ctl.states),
       controller2run(ctl),
       *[event2method(e) | e <- ctl.events ],
       *[command2method(c) | c <- ctl.commands ]
     ])[@modifiers=[\public()]]]);
       

list[Declaration] state2consts(list[State] states) {
  i = 0;
  return for (s <- states) {
    append field(\int(), [number("<i>")])[@modifiers=[\private(), \static(), \final()]];
    i += 1; 
  }
}



Declaration controller2run(Controller ctl) =
   method(\void(), "run", [parameter(simpleType(Scanner), "input", 0), parameter(simpleType(Writer), "output", 0)], [IOException],
     block([
       expressionStatement(\declarationExpression(variables(\int(), [variable("state", 0)]))),
       \while(booleanLiteral(true), block([
          expressionStatement(\declarationExpression(variables(simpleType(simpleName("String")), [variable("token", 0)]))),
          \switch(simpleName("state"), ( [] | it + state2case(s) | s <- ctl.states )) 
       ]))
     ])
   )[@modifiers=[\public()]];
   



Declaration command2method(Command command)
  = method(\void(), command.name, [parameter(simpleType(Writer), "output", 0)], [IOException],
      block([
        expressionStatement(methodCall(false, simpleName("output"), "write", [stringLiteral(command.token + "\n")])),
        expressionStatement(methodCall(false, simpleName("output"), "flush", []))
      ]))[@modifiers=[\private()]];


Declaration event2method(Event event) 
  = method(\void(), event.name, [parameter(simpleType(simpleName("String")), "token", 0)], [IOException],
      block([
        \return(methodCall(false, simpleName("token"), "equals", [stringLiteral(event.token)]))
      ]))[@modifiers=[\private()]];

   
list[Statement] state2case(State s) = [
  \case(simpleName(stateName(s))),
  block([
    *[ expressionStatement(\methodCall(false, a, [simpleName("output")])) | a <- s.actions ],
    *[ trans2stat(t) | t <- s.transitions ],
    \break()
  ])
];

Statement trans2stat(transition(e, s))
  = \if(methodCall(false, e, [simpleName("token")]),
       expressionStatement(\assignment(simpleName("state"), "=", simpleName(stateName(s)))));


str stateName(State s) = stateName(s.name);
str stateName(str s) = s;
