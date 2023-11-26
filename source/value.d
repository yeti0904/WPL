module wpl.value;

import std.conv;
import std.stdio;
import std.format;
import wpl.parser;

enum ValueType {
	Unit,
	Integer,
	String,
	File,
	Lambda,
	Variable,
	Reference,
	Array,
	Function
}

class Value {
	ValueType type;

	static UnitValue Unit() {
		return new UnitValue();
	}

	static IntegerValue Integer(long value) {
		auto ret  = new IntegerValue();
		ret.value = value;
		return ret;
	}

	static StringValue String(string value) {
		auto ret  = new StringValue();
		ret.value = value;
		return ret;
	}

	static FileValue File(std.stdio.File file) {
		auto ret  = new FileValue();
		ret.value = file;
		return ret;
	}

	static LambdaValue Lambda(Node value) {
		auto ret  = new LambdaValue();
		ret.value = value;
		return ret;
	}

	static VariableValue Variable(string value) {
		auto ret  = new VariableValue();
		ret.value = value;
		return ret;
	}

	static ReferenceValue Reference(Value* value) {
		auto ret  = new ReferenceValue();
		ret.value = value;
		return ret;
	}

	static ArrayValue Array(Value[] values) {
		auto ret   = new ArrayValue();
		ret.values = values;
		return ret;
	}
}

class UnitValue : Value {
	this() {
		type = ValueType.Unit;
	}

	override string toString() {
		return "unit";
	}
}

class IntegerValue : Value {
	long value;

	this() {
		type = ValueType.Integer;
	}

	override string toString() {
		return text(value);
	}
}

class StringValue : Value {
	string value;

	this() {
		type = ValueType.String;
	}

	override string toString() {
		return format("\"%s\"", value);
	}
}

class FileValue : Value {
	std.stdio.File value;

	this() {
		type = ValueType.File;
	}
}

class LambdaValue : Value {
	Node value;

	this() {
		type = ValueType.Lambda;
	}

	override string toString() {
		return value.toString();
	}
}

class VariableValue : Value {
	string value;

	this() {
		type = ValueType.Variable;
	}

	override string toString() {
		return value;
	}
}

class ReferenceValue : Value {
	Value* value;

	this() {
		type = ValueType.Reference;
	}

	override string toString() {
		return value.toString();
	}
}

class ArrayValue : Value {
	Value[] values;

	this() {
		type = ValueType.Array;
	}

	override string toString() {
		string ret = "[";

		foreach (ref val ; values) {
			ret ~= format("%s ", val.toString());
		}

		return ret ~ ']';
	}
}

class FunctionValue : Value {
	Node     value;
	string[] params;

	this() {
		type = ValueType.Function;
	}

	override string toString() {
		string ret = "([";

		foreach (ref param ; params) {
			ret ~= format("%s ", param);
		}

		ret ~= format("] => (%s))", value);
		return ret;
	}
}
