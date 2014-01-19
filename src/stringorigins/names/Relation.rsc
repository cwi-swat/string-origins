module stringorigins::names::Relation

import IO;
import Set;

import stringorigins::names::Names;

alias Edge = tuple[ID use, ID def];
alias Edges = map[ID use, ID def];
alias NameGraph = tuple[set[ID] V, Edges E];

set[ID] synthesizedNodes(NameGraph Gs, NameGraph Gt) = Gt.V - Gs.V;


ID refOf(ID n, Edges refs) = refs[n];
ID refOf(str n, Edges refs) = refs[getID(n)];

ID refOf(ID n, NameGraph G) = refOf(n, G.E);
ID refOf(str n, NameGraph G) = refOf(getID(n), G.E); 

bool isRefOf(str u, str d, NameGraph G) {
  uid = getID(u);
  did = getID(d);
  return uid in G.E && G.E[uid] == did;
}

set[ID] defsOf(NameGraph G) = G.E.def;

set[ID] usesOf(NameGraph G) = G.E.use;

NameGraph makeGraph(rel[str name,ID l] names, rel[ID use, ID def] refs) {
  nodes = names<1>;
  N = names<1,0>;
  
  if (size(refs<0>) != size(refs))
    throw "NameGraph requires unique mapping from name use to name def, but got <refs>";
  if (size(N<0>) != size(N))
    throw "NameGraph requires unique mapping from node labels to names, but got <N>";
  
  return <nodes, ( u:d | <u,d> <- refs )>;
}
