module wpl.operators.integer;

import std.math;
import std.stdio;
import std.format;
import wpl.value;
import wpl.interpreter;

static Value AddInt(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return Value.Integer(left + right);
}

static Value SubInt(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return Value.Integer(left - right);
}

static Value MulInt(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return Value.Integer(left * right);
}

static Value DivInt(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return Value.Integer(left / right);
}

static Value PowInt(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return Value.Integer(pow(left, right));
}

static Value ModInt(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return Value.Integer(left % right);
}

static Value IntEquals(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return left == right? Value.Integer(-1) : Value.Integer(0);
}

static Value IntNotEquals(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return left == right? Value.Integer(0) : Value.Integer(-1);
}

static Value IntLess(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return left < right? Value.Integer(-1) : Value.Integer(0);
}

static Value IntLessE(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return left <= right? Value.Integer(-1) : Value.Integer(0);
}

static Value IntGreater(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return left > right? Value.Integer(-1) : Value.Integer(0);
}

static Value IntGreaterE(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return left >= right? Value.Integer(-1) : Value.Integer(0);
}

static Value AndInt(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return Value.Integer(left & right);
}

static Value OrInt(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return Value.Integer(left | right);
}

static Value XorInt(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return Value.Integer(left ^ right);
}

static Value LShiftInt(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return Value.Integer(left << right);
}

static Value RShiftInt(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	return Value.Integer(left >> right);
}
