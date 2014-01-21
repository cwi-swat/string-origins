module stringorigins::names::Names

import String;
import util::Maybe;

alias ID = loc;

ID getID(str x) = l when  loc l <- originsOnly(x);

