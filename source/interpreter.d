module wpl.interpreter;

import std.stdio;
import core.stdc.stdlib;
import wpl.error;
import wpl.value;
import wpl.parser;
import wpl.operators;

struct Variable {
	Value value;
	uint  scopeIn; // what scope layer the variable was created in (0 = global layer)

	static Variable Global(Value value) {
		return Variable(value, 0);
	}
}

alias OperatorFunc = Value function(Value, Value, Interpreter);

struct Operator {
	string       name;
	ValueType    left;
	ValueType    right;
	OperatorFunc func;
	bool         strict;

	this(string pname, ValueType pleft, ValueType pright, OperatorFunc pfunc) {
		name      = pname;
		left      = pleft;
		right     = pright;
		func      = pfunc;
		strict    = true;
	}

	this(string pname, OperatorFunc pfunc) {
		name      = pname;
		func      = pfunc;
		strict    = false;
	}
}

struct OpMeta {
	bool evalLeft;
	bool evalRight;
}

class Interpreter {
	Variable[string] variables;
	Operator[]       ops;
	OpMeta[string]   opMeta;

	this() {
		// default variables
		variables["stdout"] = Variable.Global(Value.File(stdout));
		variables["stderr"] = Variable.Global(Value.File(stderr));
		variables["stdin"]  = Variable.Global(Value.File(stdin));

		// strict operators
		AddOp("+",  ValueType.Integer,   ValueType.Integer, &Operators.AddInt);
		AddOp("-",  ValueType.Integer,   ValueType.Integer, &Operators.SubInt);
		AddOp("*",  ValueType.Integer,   ValueType.Integer, &Operators.MulInt);
		AddOp("/",  ValueType.Integer,   ValueType.Integer, &Operators.DivInt);
		AddOp("^",  ValueType.Integer,   ValueType.Integer, &Operators.PowInt);
		AddOp("%",  ValueType.Integer,   ValueType.Integer, &Operators.ModInt);
		AddOp("<",  ValueType.Integer,   ValueType.Integer, &Operators.IntLess);
		AddOp("<=", ValueType.Integer,   ValueType.Integer, &Operators.IntLessE);
		AddOp(">",  ValueType.Integer,   ValueType.Integer, &Operators.IntGreater);
		AddOp(">=", ValueType.Integer,   ValueType.Integer, &Operators.IntGreaterE);
		AddOp(".s", ValueType.File,      ValueType.String,  &Operators.WriteString);
		AddOp(".d", ValueType.File,      ValueType.Integer, &Operators.WriteDecimal);
		AddOp("==", ValueType.Integer,   ValueType.Integer, &Operators.IntEquals);
		AddOp("/=", ValueType.Integer,   ValueType.Integer, &Operators.IntNotEquals);
		AddOp("/=", ValueType.Integer,   ValueType.Integer, &Operators.IntNotEquals);
		AddOp("?",  ValueType.Integer,   ValueType.Lambda,  &Operators.If);
		AddOp(",",  ValueType.File,      ValueType.Integer, &Operators.Read);
		AddOp(",n", ValueType.File,      ValueType.Integer, &Operators.ReadLine);
		AddOp("+",  ValueType.String,    ValueType.String,  &Operators.AddString);
		AddOp("==", ValueType.String,    ValueType.String,  &Operators.EqualsString);
		AddOp("/=", ValueType.String,    ValueType.String,  &Operators.NotEqualsString);
		AddOp("@",  ValueType.Lambda,    ValueType.Lambda,  &Operators.While);
		AddOp("+",  ValueType.Array,     ValueType.Integer, &Operators.AddArray);
		AddOp("+",  ValueType.Array,     ValueType.String,  &Operators.AddArray);
		AddOp("+",  ValueType.Array,     ValueType.Lambda,  &Operators.AddArray);
		AddOp("+",  ValueType.Array,     ValueType.Array,   &Operators.AddArray);
		AddOp(":",  ValueType.Array,     ValueType.Integer, &Operators.ArrayIndex);
		AddOp("-",  ValueType.Array,     ValueType.Integer, &Operators.ArrayLength);
		AddOp(":=", ValueType.Reference, ValueType.Integer, &Operators.RefAssign);
		AddOp(":=", ValueType.Reference, ValueType.String,  &Operators.RefAssign);
		AddOp(":=", ValueType.Reference, ValueType.Lambda,  &Operators.RefAssign);
		AddOp(":=", ValueType.Reference, ValueType.Array,   &Operators.RefAssign);
		AddOp(":",  ValueType.Reference, ValueType.Integer, &Operators.DeRef);
		AddOp(":",  ValueType.Reference, ValueType.String,  &Operators.DeRef);
		AddOp(":",  ValueType.Reference, ValueType.Lambda,  &Operators.DeRef);
		AddOp(":",  ValueType.Reference, ValueType.Array,   &Operators.DeRef);

		// not strict operators
		AddOp(";", &Operators.Chain);
		AddOp("=", &Operators.Assign);
		SetOpMeta("=", false, true);
	}

	void AddOp(string name, ValueType left, ValueType right, OperatorFunc func) {
		ops          ~= Operator(name, left, right, func);
		opMeta[name]  = OpMeta(true, true);
	}

	void AddOp(string name, OperatorFunc func) {
		ops          ~= Operator(name, func);
		opMeta[name]  = OpMeta(true, true);
	}

	void SetOpMeta(string name, bool left, bool right) {
		opMeta[name] = OpMeta(left, right);
	}

	void AssertVariable(string name, ErrorInfo info) {
		if (name !in variables) {
			ErrorBegin(info);
			stderr.writefln("No such variable: %s", name);
			exit(1);
		}
	}

	Value Evaluate(Node pnode, bool evalVariables) {
		switch (pnode.type) {
			case NodeType.Integer: {
				auto node = cast(IntegerNode) pnode;
				
				return Value.Integer(node.value);
			}
			case NodeType.String: {
				auto node = cast(StringNode) pnode;

				return Value.String(node.value);
			}
			case NodeType.Identifier: {
				auto node = cast(IdentifierNode) pnode;

				if (evalVariables) {
					AssertVariable(node.name, node.info);
					return variables[node.name].value;
				}
				else {
					return Value.Variable(node.name);
				}
			}
			case NodeType.Lambda: {
				auto node = cast(LambdaNode) pnode;

				return Value.Lambda(node.expr);
			}
			case NodeType.Array: {
				auto node = cast(ArrayNode) pnode;
				auto ret  = Value.Array([]);

				foreach (ref node2 ; node.values) {
					ret.values ~= Evaluate(node2, true);
				}

				return ret;
			}
			case NodeType.Expression: {
				auto node = cast(ExpressionNode) pnode;

				Operator op;
				Value    left;
				Value    right;
				bool     found;
				OpMeta   meta;

				if (node.op !in opMeta) goto opNotFound;

				meta = opMeta[node.op];

				left  = Evaluate(node.left, meta.evalLeft);
				right = Evaluate(node.right, meta.evalRight);
				
				foreach (ref iop ; ops) {
					if (iop.strict) {
						if (
							(iop.name == node.op) &&
							(iop.left == left.type) &&
							(iop.right == right.type) 
						) {
							found = true;
							op    = iop;
							break;
						}
					}
					else {
						if (iop.name == node.op) {
							found = true;
							op    = iop;
							break;
						}
					}
				}

				opNotFound:
				if (!found) {
					ErrorBegin(node.info);
					stderr.writefln(
						"No operator matches %s %s %s", left.type, node.op, right.type
					);
					exit(1);
				}

				return op.func(left, right, this);
			}
			default: assert(0);
		}
	}
}
