module stringorigins::escaping::Protect
import String;

str PROTECTED = "protected";

str protected(str s, str label) = tagString(s, PROTECTED, label);