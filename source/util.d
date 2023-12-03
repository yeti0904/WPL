module wpl.util;

import std.format;
import std.algorithm;
import wpl.value;
import wpl.interpreter;

void AssertType(ValueType expected, ValueType got) {
	if (expected != got) {
		throw new OperatorException(format("Expected %s, got %s", expected, got));
	}
}

bool IsInt(string str) {
	string allowedChars = "0123456789";

	foreach (ref ch ; str) {
		if (!allowedChars.canFind(ch)) return false;
	}

	return true;
}

bool IsFloat(string str) {
	bool   dot;
	string allowedChars = "0123456789";

	foreach (ref ch ; str) {
		if (ch == '.') {
			if (dot) {
				return false;
			}
			else {
				dot = true;
			}
		}
		else if (!allowedChars.canFind(ch)) return false;
	}

	return true;
}
