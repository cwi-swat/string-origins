@Requires{Desugaring: resets}
module lang::missgrant::base::Compile

import lang::missgrant::base::AST;
import stringorigins::regions::Regions;

str if_ = "if_";

str compile(str name, Controller ctl) =
       "public class <name> {
       '  private static String <if_> = \"<name>\";
       '  public static void main(String args[]) throws java.io.IOException { 
       '     new <name>().run(new java.util.Scanner(System.in), 
       '                    new java.io.PrintWriter(System.out));
       '  }
       '  <states2consts(ctl.states)>
       '  <controller2run(ctl)>
       '  <for (e <- ctl.events) {>
  	   '  <event2java(e)>
  	   '  <}>
       '  <for (c <- ctl.commands) {>
       '  <command2java(c)>
       '  <}>
       '}";

str states2consts(list[State] states) {
  i = 0;
  return "<for (s <- states) {>
         'private static final int <stateName(s)> = <i>;
         '<i += 1;}>"; 
}

str command2java(Command command) =
         "private void <command.name>(java.io.Writer output) throws java.io.IOException {
         '  System.err.println(\"Executing <command.name>\");
         '  int <command.name>_var;
         '  output.write(\"<command.token>\\n\");
         '  output.flush();
         '  <regionize("// Add more code here", command.name)>
         '}";

str event2java(Event event) =
         "private boolean <event.name>(String token) {
         '  return token.equals(\"<event.token>\");
         '}";


str controller2run(Controller ctl) =
         "void run(java.util.Scanner input, java.io.Writer output) throws java.io.IOException {
         '  int state = <stateName(ctl.states[0])>;
         '  while (true) {
         '    String token = input.nextLine();
         '    switch (state) {
         '      <for (s <- ctl.states) {>
         '      <state2case(s)>
         '      <}>
         '    }
         '  }
         '}";

str state2case(State s) =
         "case <stateName(s)>: {
         '  // Handle <stateName(s)>
         '  <for (a <- s.actions) {>
         '     <a>(output);
         '  <}>
         '  <for (transition(e, s2) <- s.transitions) {>
         '  if (<e>(token)) {
         '     state = <stateName(s2)>;
         '  }
         '  <}>
         '  break;
         '}";

str stateName(State s) = stateName(s.name);
str stateName(str s) = s; //"state$<s>";
