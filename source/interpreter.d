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
	bool         evalLeft;
	bool         evalRight;

	this(string pname, ValueType pleft, ValueType pright, bool eLeft, bool eRight, OperatorFunc pfunc) {
		name      = pname;
		left      = pleft;
		right     = pright;
		func      = pfunc;
		evalLeft  = eLeft;
		evalRight = eRight;
		strict = true;
	}

	this(string pname, OperatorFunc pfunc) {
		name   = pname;
		func   = pfunc;
		strict = false;
	}
}

class Interpreter {
	Variable[string] variables;
	Operator[]       ops;

	this() {
		// default variables
		variables["stdout"] = Variable.Global(Value.File(stdout));
		variables["stderr"] = Variable.Global(Value.File(stderr));
		variables["stdin"]  = Variable.Global(Value.File(stdin));

		// strict operators
		AddOp("+",  ValueType.Integer, ValueType.Integer, true, true,  &Operators.AddInt);
		AddOp("-",  ValueType.Integer, ValueType.Integer, true, true,  &Operators.SubInt);
		AddOp("*",  ValueType.Integer, ValueType.Integer, true, true,  &Operators.MulInt);
		AddOp("/",  ValueType.Integer, ValueType.Integer, true, true,  &Operators.DivInt);
		AddOp("^",  ValueType.Integer, ValueType.Integer, true, true,  &Operators.PowInt);
		AddOp("%",  ValueType.Integer, ValueType.Integer, true, true,  &Operators.ModInt);
		AddOp(".s", ValueType.File,    ValueType.String,  true, true,  &Operators.WriteString);
		AddOp(".d", ValueType.File,    ValueType.Integer, true, true,  &Operators.WriteDecimal);
		AddOp("==", ValueType.Integer, ValueType.Integer, true, true,  &Operators.IntEquals);
		AddOp("/=", ValueType.Integer, ValueType.Integer, true, true,  &Operators.IntNotEquals);
		AddOp("/=", ValueType.Integer, ValueType.Integer, true, true,  &Operators.IntNotEquals);
		AddOp("?",  ValueType.Integer, ValueType.Lambda,  true, true,  &Operators.If);

		// not strict operators
		AddOp(";", &Operators.Chain);
		AddOp("=", &Operators.Assign);
	}

	void AddOp(string name, ValueType left, ValueType right, bool eLeft, bool eRight, OperatorFunc func) {
		ops ~= Operator(name, left, right, eLeft, eRight, func);
	}

	void AddOp(string name, OperatorFunc func) {
		ops ~= Operator(name, func);
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
			case NodeType.Expression: {
				auto node = cast(ExpressionNode) pnode;
				
				// look for operator
				Operator op;
				bool     found;
				foreach (ref iop ; ops) {
					if (iop.name == node.op) {
						found = true;
						op    = iop;
					}
				}

				auto left  = Evaluate(node.left, op.evalLeft);
				auto right = Evaluate(node.right, op.evalRight);

				if (op.strict) {
					if (
						(op.left != left.type) ||
						(op.right != right.type)
					) {
						found = false;
					}
				}

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
