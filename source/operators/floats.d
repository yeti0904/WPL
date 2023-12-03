module wpl.operators.floats;

import std.math;
import std.stdio;
import std.format;
import wpl.value;
import wpl.interpreter;

static Value AddFloat(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(FloatValue) pleft).value;
	auto right = (cast(FloatValue) pright).value;

	return Value.Float(left + right);
}

static Value SubFloat(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(FloatValue) pleft).value;
	auto right = (cast(FloatValue) pright).value;

	return Value.Float(left - right);
}

static Value MulFloat(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(FloatValue) pleft).value;
	auto right = (cast(FloatValue) pright).value;

	return Value.Float(left * right);
}

static Value DivFloat(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(FloatValue) pleft).value;
	auto right = (cast(FloatValue) pright).value;

	return Value.Float(left / right);
}

static Value PowFloat(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(FloatValue) pleft).value;
	auto right = (cast(FloatValue) pright).value;

	return Value.Float(pow(left, right));
}

static Value ModFloat(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(FloatValue) pleft).value;
	auto right = (cast(FloatValue) pright).value;

	return Value.Float(left % right);
}

static Value FloatEquals(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(FloatValue) pleft).value;
	auto right = (cast(FloatValue) pright).value;

	return left == right? Value.Float(-1) : Value.Float(0);
}

static Value FloatNotEquals(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(FloatValue) pleft).value;
	auto right = (cast(FloatValue) pright).value;

	return left == right? Value.Float(0) : Value.Float(-1);
}

static Value FloatLess(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(FloatValue) pleft).value;
	auto right = (cast(FloatValue) pright).value;

	return left < right? Value.Float(-1) : Value.Float(0);
}

static Value FloatLessE(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(FloatValue) pleft).value;
	auto right = (cast(FloatValue) pright).value;

	return left <= right? Value.Float(-1) : Value.Float(0);
}

static Value FloatGreater(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(FloatValue) pleft).value;
	auto right = (cast(FloatValue) pright).value;

	return left > right? Value.Float(-1) : Value.Float(0);
}

static Value FloatGreaterE(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(FloatValue) pleft).value;
	auto right = (cast(FloatValue) pright).value;

	return left >= right? Value.Float(-1) : Value.Float(0);
}
