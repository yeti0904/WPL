module wpl.operators.variables;

import std.math;
import std.stdio;
import std.format;
import wpl.value;
import wpl.interpreter;

static Value Assign(Value pleft, Value pright, Interpreter env) {
	if (pleft.type != ValueType.Variable) {
		throw new OperatorException("Assign operator expects variable to assign to");
	}
	auto left = (cast(VariableValue) pleft).value;

	// env.variables[left] = Variable(pright, 0);
	env.SetVariable(left, Variable(pright));
	return Value.Reference(env.GetVariableRef(left));
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
