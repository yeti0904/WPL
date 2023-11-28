module wpl.builtins;

import std.file;
import std.stdio;
import std.format;
import std.exception;
import std.datetime;
import core.memory;
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

Value Time(Value[] args, Interpreter env) {
	AssertArgs(args, []);

	return Value.Integer(Clock.currTime().toUnixTime());
}

Value Open(Value[] args, Interpreter env) {
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

Value Flush(Value[] args, Interpreter env) {
	AssertArgs(args, [ValueType.File]);

	auto file = (cast(FileValue) args[0]).value;
	file.flush();

	return Value.Unit();
}

Value Close(Value[] args, Interpreter env) {
	AssertArgs(args, [ValueType.File]);

	auto file = (cast(FileValue) args[0]).value;
	file.close();

	return Value.Unit();
}

Value Mkdir(Value[] args, Interpreter env) {
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

Value FExists(Value[] args, Interpreter env) {
	AssertArgs(args, [ValueType.String]);

	auto path = (cast(StringValue) args[0]).value;

	return exists(path)? Value.Integer(-1) : Value.Integer(0);
}

Value Alloc(Value[] args, Interpreter env) {	
	AssertArgs(args, [ValueType.Integer]);

	auto size = (cast(IntegerValue) args[0]).value;
	auto ret  = new PointerValue();
	ret.value = pureMalloc(size);

	if (ret.value is null) {
		throw new OperatorException(format("malloc(%d) failed", size));
	}
	
	return ret;
}

Value Realloc(Value[] args, Interpreter env) {
	AssertArgs(args, [ValueType.Pointer, ValueType.Integer]);

	auto ptr  = (cast(PointerValue) args[0]).value;
	auto size = (cast(IntegerValue) args[1]).value;
	auto ret  = new PointerValue();
	ret.value = pureRealloc(ptr, size);

	if (ret.value is null) {
		throw new OperatorException(format("realloc(%s, %d) failed", ptr, size));
	}

	return ret;
}

Value Free(Value[] args, Interpreter env) {
	AssertArgs(args, [ValueType.Pointer]);

	auto ptr = (cast(PointerValue) args[0]).value;
	pureFree(ptr);
	return Value.Unit();
}
