module wpl.builtins;

import std.file;
import std.stdio;
import std.format;
import std.exception;
import std.datetime;
import wpl.value;
import wpl.interpreter;

private void AssertArgs(Value[] args, ValueType[] expected) {
	if (args.length != expected.length) {
		throw new OperatorException(format(
			"Expected %d parameters, got %d", expected.length, args.length
		));
	}

	foreach (i, ref arg ; args) {
		if (arg.type != expected[i]) {
			throw new OperatorException(format(
				"Expected %s, got %s for parameter %d", expected[i], arg.type, i
			));
		}
	}
}

Value Time(Value[] args, Interpreter func) {
	AssertArgs(args, []);

	return Value.Integer(Clock.currTime().toUnixTime());
}

Value Open(Value[] args, Interpreter func) {
	AssertArgs(args, [ValueType.String, ValueType.String]);

	File ret;
	auto path = (cast(StringValue) args[0]).value;
	auto mode = (cast(StringValue) args[1]).value;

	try {
		ret = File(path, mode);
	}
	catch (ErrnoException e) {
		throw new OperatorException(e.msg);
	}

	return Value.File(ret);
}

Value Flush(Value[] args, Interpreter func) {
	AssertArgs(args, [ValueType.File]);

	auto file = (cast(FileValue) args[0]).value;
	file.flush();

	return Value.Unit();
}

Value Close(Value[] args, Interpreter func) {
	AssertArgs(args, [ValueType.File]);

	auto file = (cast(FileValue) args[0]).value;
	file.close();

	return Value.Unit();
}

Value Mkdir(Value[] args, Interpreter func) {
	AssertArgs(args, [ValueType.String]);

	auto path = (cast(StringValue) args[0]).value;

	try {
		mkdir(path);
	}
	catch (Exception e) {
		throw new OperatorException(e.msg);
	}

	return Value.Unit();
}

Value FExists(Value[] args, Interpreter func) {
	AssertArgs(args, [ValueType.String]);

	auto path = (cast(StringValue) args[0]).value;

	return exists(path)? Value.Integer(-1) : Value.Integer(0);
}
