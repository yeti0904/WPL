module wpl.operators.imperative;

import std.math;
import std.stdio;
import std.format;
import wpl.value;
import wpl.interpreter;

static Value Chain(Value pleft, Value pright, Interpreter env) {
	if (pright.type != ValueType.Unit) {
		return pright;
	}

	return Value.Unit();
}

static Value If(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(IntegerValue) pleft).value;
	auto right = (cast(LambdaValue) pright).value;

	if (left != 0) {
		return env.Evaluate(right, true);
	}

	return Value.Unit();
}

static Value While(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(LambdaValue) pleft).value;
	auto right = (cast(LambdaValue) pright).value;

	auto res = env.Evaluate(left, true);
	if (res.type != ValueType.Integer) {
		throw new OperatorException("Condition didn't return integer");
	}

	while ((cast(IntegerValue) res).value) {
		env.Evaluate(right, true);
	
		res = env.Evaluate(left, true);
		if (res.type != ValueType.Integer) {
			throw new OperatorException("Condition didn't return integer");
		}
	}

	return Value.Unit();
}
