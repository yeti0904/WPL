module wpl.operators;

import std.math;
import std.stdio;
import std.format;
import wpl.value;
import wpl.interpreter;

class OperatorException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}

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
		if (pleft.type != ValueType.Variable) {
			throw new OperatorException("Assign operator expects variable to assign to");
		}
		auto left = (cast(VariableValue) pleft).value;

		env.variables[left] = Variable(pright, 0);
		return Value.Reference(&env.variables[left].value);
	}

	static Value Read(Value pleft, Value pright, Interpreter env) {
		auto left  = (cast(FileValue) pleft).value;
		auto right = (cast(IntegerValue) pright).value;

		auto ret = left.rawRead(new ubyte[](right));
		return Value.String(cast(string) ret);
	}

	static Value ReadLine(Value pleft, Value pright, Interpreter env) {
		auto left  = (cast(FileValue) pleft).value;
		auto right = (cast(IntegerValue) pright).value;

		auto ret = left.readln();
		return Value.String(ret);
	}

	// string ops
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

	// array ops
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

	static Value RefAssign(Value pleft, Value pright, Interpreter env) {
		auto left = cast(ReferenceValue) pleft;

		return (*left.value) = pright;
	}

	static Value DeRef(Value pleft, Value pright, Interpreter env) {
		auto left = cast(ReferenceValue) pleft;

		if (left.value is null) return pright;
		else                    return *left.value;
	}

	static Value Function(Value pleft, Value pright, Interpreter env) {
		auto left  = cast(ArrayValue) pleft;
		auto right = (cast(LambdaValue) pright).value;

		auto func = new FunctionValue();
		foreach (ref arg ; left.values) {
			auto var     = cast(VariableValue) arg;
			func.params ~= var.value;
		}

		func.value = right;
		return func;
	}

	static Value Call(Value pleft, Value pright, Interpreter env) {
		auto left  = cast(FunctionValue) pleft;
		auto right = cast(ArrayValue) pright;

		// move into a new scope Lets Fucking Go
		++ env.topScope;

		if (right.values.length != left.params.length) {
			throw new OperatorException(format(
				"Expected %d parameters, got %d", right.values.length,
				left.params.length
			));
		}

		foreach (i, ref param ; right.values) {
			env.variables[left.params[i]] = Variable(param, env.topScope);
		}

		auto ret = env.Evaluate(left.value, true);

		-- env.topScope;
		bool scopeCleared = true;
		do {
			scopeCleared = true;
			foreach (key, ref value ; env.variables) {
				if (value.scopeIn > env.topScope) {
					env.variables.remove(key);
					scopeCleared = false;
					break;
				}
			}
		} while (!scopeCleared);

		return ret;
	}

	// boolean ops
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
}
