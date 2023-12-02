module wpl.operators.array;

import std.math;
import std.stdio;
import std.algorithm;
import std.format;
import wpl.value;
import wpl.interpreter;

static Value AddArray(Value pleft, Value pright, Interpreter env) {
	auto left = cast(ArrayValue) pleft;

	left.values ~= pright;
	return left;
}

static Value ArrayIndex(Value pleft, Value pright, Interpreter env) {
	auto left  = cast(ArrayValue) pleft;
	auto right = (cast(IntegerValue) pright).value;

	if ((right >= left.values.length) || (right < 0)) {
		throw new OperatorException(format(
			"Array index (%d) out of bounds (%d)", right, left.values.length
		));
	}

	return Value.Reference(&left.values[right]);
}

static Value ArrayLength(Value pleft, Value pright, Interpreter env) {
	auto left  = cast(ArrayValue) pleft;
	auto right = (cast(IntegerValue) pright).value;

	return Value.Integer(left.values.length - right);
}

static Value ArrayRemove(Value pleft, Value pright, Interpreter env) {
	auto left  = cast(ArrayValue) pleft;
	auto right = (cast(IntegerValue) pright).value;
	
	if ((right >= left.values.length) || (right < 0)) {
		throw new OperatorException(format(
			"Array index (%d) out of bounds (%d)", right, left.values.length
		));
	}

	left.values = left.values.remove(right);
	return Value.Unit();
}
