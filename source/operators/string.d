module wpl.operators.strings;

import std.math;
import std.stdio;
import std.format;
import wpl.value;
import wpl.interpreter;

static Value AddString(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(StringValue) pleft).value;
	auto right = (cast(StringValue) pright).value;

	return Value.String(left ~ right);
}

static Value EqualsString(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(StringValue) pleft).value;
	auto right = (cast(StringValue) pright).value;

	return left == right? Value.Integer(-1) : Value.Integer(0);
}

static Value NotEqualsString(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(StringValue) pleft).value;
	auto right = (cast(StringValue) pright).value;

	return left == right? Value.Integer(0) : Value.Integer(-1);
}
