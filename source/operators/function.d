module wpl.operators.functions;

import std.math;
import std.stdio;
import std.format;
import wpl.value;
import wpl.interpreter;

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
