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

	if (right.values.length != left.params.length) {
		throw new OperatorException(format(
			"Expected %d parameters, got %d", right.values.length,
			left.params.length
		));
	}

	Value ret;

	if (left.builtIn) {
		ret = left.func(right.values, env);
	}
	else {
		env.AddScope();
		foreach (i, ref param ; right.values) {
			// env.variables[left.params[i]] = Variable(param, env.topScope);
			env.SetLocal(left.params[i], Variable(param));
		}
		
		ret = env.Evaluate(left.value, true);
		env.RemoveScope();
	}

	return ret;
}
