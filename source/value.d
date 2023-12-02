module wpl.value;

import std.conv;
import std.stdio;
import std.format;
import wpl.parser;
import wpl.interpreter;

enum ValueType {
	Unit,
	Integer,
	String,
	File,
	Lambda,
	Variable,
	Reference,
	Array,
	Function,
	Pointer,
	Structure,
	CharRef
}

enum LLType { // Low Level Type
	U8,
	U16,
	U32,
	U64,
	I8,
	I16,
	I32,
	I64
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

alias BuiltInFunc = Value function(Value[], Interpreter);

class FunctionValue : Value {
	bool        builtIn;
	Node        value;
	string[]    params;
	BuiltInFunc func;

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

class PointerValue : Value {
	void*  value;
	LLType ptype;

	this() {
		type = ValueType.Pointer;
	}

	override string toString() {
		return format("%.8X", cast(ulong) value);
	}

	T Read(T)() {
		return *(cast(T*) value);
	}

	void Write(T)(T data) {
		*(cast(T*) value) = data;
	}
}

class StructureValue : Value {
	Value[string] values;

	this() {
		type = ValueType.Structure;
	}

	override string toString() {
		string ret = "(";

		foreach (key, ref value ; values) {
			ret ~= value.toString() ~ ' ';
		}

		return ret ~ ')';
	}
}

class CharRefValue : Value {
	char* value;

	this() {
		type = ValueType.CharRef;
	}

	override string toString() {
		return format("%.8X (%c)", cast(ulong) value, *value);
	}
}
