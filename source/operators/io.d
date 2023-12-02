module wpl.operators.io;

import std.math;
import std.stdio;
import std.format;
import wpl.value;
import wpl.interpreter;

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

static Value ReadByte(Value pleft, Value pright, Interpreter env) {
	auto left = (cast(FileValue) pleft).value;

	if (left.eof) {
		return pright;
	}

	return Value.Integer(left.rawRead(new ubyte[1])[0]);
}
