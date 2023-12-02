module wpl.util;

import std.format;
import wpl.value;
import wpl.interpreter;

void AssertType(ValueType expected, ValueType got) {
	if (expected != got) {
		throw new OperatorException(format("Expected %s, got %s", expected, got));
	}
}
