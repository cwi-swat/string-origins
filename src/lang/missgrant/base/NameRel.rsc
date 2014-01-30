module lang::missgrant::base::NameRel

import lang::missgrant::base::AST;

import stringorigins::names::Relation;
import stringorigins::names::Names;


map[str,ID] collectStates(Controller ctl) =
  ( s.name: getID(s.name) | /State s := ctl );

NameGraph relateStates(Controller ctl, map[str,ID] stateDefs) {
  states = stateDefs<0,1>;
  transitionNames = { <t.state, getID(t.state)> | /Transition t := ctl };
  rels = { <getID(t.state), stateDefs[t.state]> | /Transition t := ctl };
  return makeGraph(states + transitionNames, rels);
}

NameGraph resolveNames(Controller ctl) =
  relateStates(ctl, collectStates(ctl));
  
loc origin(str x) = getID(x);

alias G = rel[loc use, loc def];

G resolve(Controller ctl) {  
  sd = ( x: origin(x) | /state(x, _, _) := ctl );
  ed = ( x: origin(x) | /event(x, _) := ctl);
  return { <origin(e), ed[e]>, <origin(s), sd[s]> 
              | /transition(e, s) := ctl };
}
