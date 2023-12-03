module wpl.operators.structure;

import std.format;
import wpl.value;
import wpl.interpreter;

static Value Structure(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(StructureDefValue) pleft).values.dup;
	auto right = (cast(VariableValue) pright).value;

	left ~= right;
	
	auto ret   = new StructureDefValue();
	ret.values = left;
	return ret;
}

static Value AssignStructure(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(VariableValue) pleft).value;
	auto right = (cast(StructureDefValue) pright).values;

	auto ret = new StructureValue();
	foreach (ref member ; right) {
		ret.values[member] = Value.Unit();
	}

	env.SetVariable(left, Variable(ret));
	return Value.Reference(env.GetVariableRef(left));
}

static Value StructMember(Value pleft, Value pright, Interpreter env) {
	auto left  = cast(StructureValue) pleft;
	auto right = (cast(VariableValue) pright).value;

	if (right !in left.values) {
		throw new OperatorException(format("Member '%s' doesn't exist", right));
	}

	return Value.Reference(&left.values[right]);
}

static Value StructMemberValue(Value pleft, Value pright, Interpreter env) {
	auto left  = cast(StructureValue) pleft;
	auto right = (cast(VariableValue) pright).value;

	if (right !in left.values) {
		throw new OperatorException(format("Member '%s' doesn't exist", right));
	}

	return left.values[right];
}
