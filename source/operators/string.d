module wpl.operators.strings;

import std.conv;
import std.math;
import std.stdio;
import std.format;
import wpl.util;
import wpl.value;
import wpl.interpreter;

static Value AddString(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(StringValue) pleft).value;
	auto right = (cast(StringValue) pright).value;

	return Value.String(left ~ right);
}

static Value EqualsString(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(StringValue) pleft).value;
	auto right = (cast(StringValue) pright).value;

	return left == right? Value.Integer(-1) : Value.Integer(0);
}

static Value NotEqualsString(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(StringValue) pleft).value;
	auto right = (cast(StringValue) pright).value;

	return left == right? Value.Integer(0) : Value.Integer(-1);
}

static Value IndexString(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(StringValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;

	if ((right >= left.length) || (right < 0)) {
		throw new OperatorException(format(
			"Array index (%d) out of bounds (%d)", right, left.length
		));
	}

	auto ret  = new CharRefValue();
	ret.value = &(cast(char) left[right]);
	return ret;
}

static Value WriteChar(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(CharRefValue) pleft).value;
	auto right = (cast(StringValue) pright).value;

	if (right.length != 1) {
		throw new OperatorException("Right operand is not 1 character long");
	}

	*left = right[0];
	return Value.Unit();
}

static Value DerefChar(Value pleft, Value pright, Interpreter env) {
	auto left = (cast(CharRefValue) pleft).value;
	
	if (left is null) return pright;

	auto ret  = new StringValue();
	ret.value = "" ~ *left;
	return ret;
}

static Value StringLength(Value pleft, Value pright, Interpreter env) {
	auto left  = (cast(StringValue) pleft).value;
	auto right = (cast(IntegerValue) pright).value;
	auto ret   = new IntegerValue();
	ret.value  = left.length - right;
	return ret;
}

static Value StringFormat(Value pleft, Value pright, Interpreter env) {
	auto left = (cast(StringValue) pleft).value;

	bool   noSpec = true;
	string ret;
	for (size_t i = 0; i < left.length; ++ i) {
		switch (left[i]) {
			case '%': {
				if (!noSpec) goto default;
				
				++ i;

				if (i == left.length) continue;

				switch (left[i]) {
					case 's': {
						AssertType(ValueType.String, pright.type);

						auto right = (cast(StringValue) pright).value;

						ret    ~= right;
						noSpec  = false;
						break;
					}
					case 'd': {
						AssertType(ValueType.Integer, pright.type);

						auto right = (cast(IntegerValue) pright).value;

						ret    ~= text(right);
						noSpec  = false;
						break;
					}
					case 'x':
					case 'X': {
						AssertType(ValueType.Integer, pright.type);

						auto right = (cast(IntegerValue) pright).value;

						ret    ~= format(left[i] == 'X'? "%X" : "%x", right);
						noSpec  = false;
						break;
					}
					default: continue;
				}
				break;
			}
			default: ret ~= left[i];
		}
	}

	if (noSpec) {
		throw new OperatorException("No format specifier");
	}

	return Value.String(ret);
}
