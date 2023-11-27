module wpl.operators.logic;

import std.math;
import std.stdio;
import std.format;
import wpl.value;
import wpl.interpreter;

static Value BoolAnd(Value pleft, Value pright, Interpreter env) {
	auto left  = env.Evaluate((cast(LambdaValue) pleft).value, true);
	if (left.type != ValueType.Integer) {
		throw new OperatorException(format(
			"Left returned %s, expected Integer", left.type
		));
	}

	if (!((cast(IntegerValue) left).value)) return Value.Integer(0);
	
	auto right = env.Evaluate((cast(LambdaValue) pright).value, true);
	
	if (right.type != ValueType.Integer) {
		throw new OperatorException(format(
			"Right returned %s, expected Integer", right.type
		));
	}

	return ((cast(IntegerValue) right).value)? Value.Integer(-1) : Value.Integer(0);
}

static Value BoolOr(Value pleft, Value pright, Interpreter env) {
	auto left  = env.Evaluate((cast(LambdaValue) pleft).value, true);
	if (left.type != ValueType.Integer) {
		throw new OperatorException(format(
			"Left returned %s, expected Integer", left.type
		));
	}

	if ((cast(IntegerValue) left).value) return Value.Integer(-1);
	
	auto right = env.Evaluate((cast(LambdaValue) pright).value, true);
	
	if (right.type != ValueType.Integer) {
		throw new OperatorException(format(
			"Right returned %s, expected Integer", right.type
		));
	}

	return ((cast(IntegerValue) right).value)? Value.Integer(-1) : Value.Integer(0);
}
