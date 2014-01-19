module lang::missgrant::base::Compile2JS

import lang::missgrant::base::AST;
import stringorigins::escaping::Protect;
import stringorigins::sourcemaps::SourceMaps;


str ctlSourceMap(str compiled, loc input, loc output, set[str] names)
  = generateSourceMap(compiled, input, output, names = names);

str compile2js(str name, Controller ctl) =
       "<name> = (function () {
       '  var <name> = {};
       '  <states2consts(name, ctl.states)>
       '  <controller2run(name, ctl)>
       '  <for (e <- ctl.events) {>
       '  <event2js(name, e)>
       '  <}>
       '  <for (c <- ctl.commands) {>
       '  <command2js(name, c)>
       '  <}>
       '  return <name>;
       '})();
       '
       '//# sourceMappingURL=<name>.js.map
       '";

str states2consts(str obj, list[State] states) {
  i = 0;
  return "<for (s <- states) {>
         '<obj>.<stateName(s)> = <i>;
         '<i += 1;}>"; 
}

str command2js(str obj, Command command) =
         "<obj>.<command.name> = function() {
         '  console.log(\"<command.token>\");
         '};";

str event2js(str obj, Event event) =
         "<obj>.<event.name> = function(token) {
         '  return token === \"<event.token>\";
         '};";


str controller2run(str obj, Controller ctl) =
         "<obj>.run = function(input) {
         '  var state = this.<stateName(ctl.states[0])>;
         '  for (var i = 0; i \< input.length; i++) {
         '    var token = input[i];
         '    switch (state) {
         '      <for (s <- ctl.states) {>
         '      <state2case(s)>
         '      <}>
         '    }
         '  }
         '};";

str state2case(State s) =
         "case this.<stateName(s)>: {
         '  <for (a <- s.actions) {>
         '     this.<a>();
         '  <}>
         '  <for (transition(e, s2) <- s.transitions) {>
         '  if (this.<e>(token)) {
         '     state = this.<stateName(s2)>;
         '  }
         '  <}>
         '  break;
         '}";

str stateName(State s) = stateName(s.name);
str stateName(str s) = "state$<s>";
