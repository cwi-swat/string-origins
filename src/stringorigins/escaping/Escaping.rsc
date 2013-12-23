module stringorigins::escaping::Escaping

import String;
import util::Maybe;
import IO;

// TODO: this use of maps for escaping is bad!
// (especially considering the looping-over-the-map
// implementation in string-origins)

map[str, str] htmlEscapes()
  = (//"&": "&amp;", 
    "\<": "&lt;", "\>": "&gt;");
  
map[str, str] latexEscapes()
  = ("\\": "$\\backslash$" /* , "$": "\\$", "%": "\\%" */);

map[str, str] stringEscapes()
  = ("\\": "\\\\", "\n": "\\n", "\t": "\\t", 
     "\r": "\\r", "\"": "\\\"");
     
str escapeAsString(str x) = tagString(x, "escape", "string");
str escapeAsLatex(str x) = tagString(x, "escape", "latex");
str escapeAsHTML(str x) = tagString(x, "escape", "html");

     
bool needEscape(loc l, str kind) 
  = (/escape=<k:[a-z]+>/ := l.query && k == kind);

str multiEscape(str x) {
  result = "";
  for (<org, s> <- origins(x)) {
    if (just(loc l) := org) {
      if (needEscape(l, "string")) {
        result += escape(s, stringEscapes());
      }
      else if (needEscape(l, "latex")) {
        result += escape(s, latexEscapes());
      }
      else if (needEscape(l, "html")) {
        result += escape(s, htmlEscapes());
      }
      else {
        result += s;
      }
    }
    else { // nothing
      result += s;
    }
  }
  return result;
}


test bool escape1() {
  s = "abc" + escapeAsHTML("\<\>") + "cdef";
  e = multiEscape(s);
  return e == "abc&lt;&gt;cdef";
}


test bool escape2() {
  s = "abc" + escapeAsHTML("\<\>") + "cdef" + escapeAsLatex("\\def\\bla") ;
  e = multiEscape(s);
  return e == "abc&lt;&gt;cdef$\\backslash$def$\\backslash$bla";
}

  
