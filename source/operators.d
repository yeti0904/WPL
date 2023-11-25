module wpl.operators;

import std.math;
import std.stdio;
import wpl.value;
import wpl.interpreter;

class Operators {
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

	static Value WriteString(Value pleft, Value pright, Interpreter env) {
		auto left  = (cast(FileValue) pleft).value;
		auto right = (cast(StringValue) pright).value;

		left.write(right);
		return Value.Unit();
	}

	static Value WriteDecimal(Value pleft, Value pright, Interpreter env) {
		auto left  = (cast(FileValue) pleft).value;
		auto right = (cast(IntegerValue) pright).value;

		left.writef("%d", right);
		return Value.Unit();
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

	static Value Assign(Value pleft, Value pright, Interpreter env) {
		// TODO: error checking on this
		auto left = (cast(VariableValue) pleft).value;

		env.variables[left] = Variable(pright, 0);
		return Value.Reference(env.variables[left].value);
	}
}
