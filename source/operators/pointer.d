module wpl.operators.pointer;

import std.math;
import std.stdio;
import std.format;
import wpl.value;
import wpl.interpreter;

private LLType StringToLLType(string str) {
	switch (str) {
		case "u8":  return LLType.U8;
		case "u16": return LLType.U16;
		case "u32": return LLType.U32;
		case "u64": return LLType.U64;
		case "i8":  return LLType.I8;
		case "i16": return LLType.I16;
		case "i32": return LLType.I32;
		case "i64": return LLType.I64;
		default:    throw new OperatorException(format("Unknown LLType %s", str));
	}
}

static Value PointerType(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(PointerValue) pleft).value;
	auto right = (cast(VariableValue) pright).value;
	auto ret   = new PointerValue();
	ret.ptype  = StringToLLType(right);
	ret.value  = left;
	return ret;
}

static Value PointerWrite(Value pleft, Value pright, Interpreter env) {
	auto left  = cast(PointerValue) pleft;
	auto right = (cast(IntegerValue) pright).value;

	final switch (left.ptype) {
		case LLType.U8:  left.Write(cast(ubyte) right);  break;
		case LLType.U16: left.Write(cast(ushort) right); break;
		case LLType.U32: left.Write(cast(uint) right);   break;
		case LLType.U64: left.Write(cast(ulong) right);  break;
		case LLType.I8:  left.Write(cast(byte) right);   break;
		case LLType.I16: left.Write(cast(short) right);  break;
		case LLType.I32: left.Write(cast(int) right);    break;
		case LLType.I64: left.Write(cast(long) right);   break;
	}

	return Value.Unit();
}

static Value PointerRead(Value pleft, Value pright, Interpreter env) {
	auto left = cast(PointerValue) pleft;

	if (left.value is null) return pright;

	auto ret = new IntegerValue();

	final switch (left.ptype) {
		case LLType.U8:  ret.value = left.Read!ubyte();  break;
		case LLType.U16: ret.value = left.Read!ushort(); break;
		case LLType.U32: ret.value = left.Read!uint();   break;
		case LLType.U64: ret.value = left.Read!ulong();  break;
		case LLType.I8:  ret.value = left.Read!byte();   break;
		case LLType.I16: ret.value = left.Read!short();  break;
		case LLType.I32: ret.value = left.Read!int();    break;
		case LLType.I64: ret.value = left.Read!long();   break;
	}

	return ret;
}

static Value PointerAdd(Value pleft, Value pright, Interpreter env) {
	auto left  = cast(PointerValue) pleft;
	auto right = (cast(IntegerValue) pright).value;

	size_t offset = right;
	final switch (left.ptype) {
		case LLType.U8:
		case LLType.I8:  break;
		case LLType.U16:
		case LLType.I16: offset *= 2; break;
		case LLType.U32:
		case LLType.I32: offset *= 4; break;
		case LLType.U64:
		case LLType.I64: offset *= 8; break;
	}

	auto ret  = new PointerValue();
	ret.ptype = left.ptype;
	ret.value = left.value + offset;
	return ret;
}

static Value PointerSub(Value pleft, Value pright, Interpreter env) {
	auto left  = cast(PointerValue) pleft;
	auto right = (cast(IntegerValue) pright).value;

	size_t offset = right;
	final switch (left.ptype) {
		case LLType.U8:
		case LLType.I8:  break;
		case LLType.U16:
		case LLType.I16: offset *= 2; break;
		case LLType.U32:
		case LLType.I32: offset *= 4; break;
		case LLType.U64:
		case LLType.I64: offset *= 8; break;
	}

	auto ret  = new PointerValue();
	ret.ptype = left.ptype;
	ret.value = left.value - offset;
	return ret;
}
