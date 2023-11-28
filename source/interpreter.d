module wpl.interpreter;

import std.stdio;
import core.stdc.stdlib;
import wpl.error;
import wpl.value;
import wpl.parser;
import wpl.builtins;
import wpl.operators.io;
import wpl.operators.array;
import wpl.operators.logic;
import wpl.operators.strings;
import wpl.operators.integer;
import wpl.operators.functions;
import wpl.operators.variables;
import wpl.operators.imperative;

struct Variable {
	Value value;
}

alias OperatorFunc = Value function(Value, Value, Interpreter);

class OperatorException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}

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
	Variable[string][] scopes;
	Operator[]         ops;
	OpMeta[string]     opMeta;

	this() {
		// create global scope
		AddScope();
	
		// default variables
		SetVariable("stdout", Variable(Value.File(stdout)));
		SetVariable("stderr", Variable(Value.File(stderr)));
		SetVariable("stdin",  Variable(Value.File(stdin)));

		// strict operators
		AddOp("+",  ValueType.Integer,   ValueType.Integer, &AddInt);
		AddOp("-",  ValueType.Integer,   ValueType.Integer, &SubInt);
		AddOp("*",  ValueType.Integer,   ValueType.Integer, &MulInt);
		AddOp("/",  ValueType.Integer,   ValueType.Integer, &DivInt);
		AddOp("^",  ValueType.Integer,   ValueType.Integer, &PowInt);
		AddOp("%",  ValueType.Integer,   ValueType.Integer, &ModInt);
		AddOp("<",  ValueType.Integer,   ValueType.Integer, &IntLess);
		AddOp("<=", ValueType.Integer,   ValueType.Integer, &IntLessE);
		AddOp(">",  ValueType.Integer,   ValueType.Integer, &IntGreater);
		AddOp(">=", ValueType.Integer,   ValueType.Integer, &IntGreaterE);
		AddOp(".s", ValueType.File,      ValueType.String,  &WriteString);
		AddOp(".d", ValueType.File,      ValueType.Integer, &WriteDecimal);
		AddOp("==", ValueType.Integer,   ValueType.Integer, &IntEquals);
		AddOp("/=", ValueType.Integer,   ValueType.Integer, &IntNotEquals);
		AddOp("/=", ValueType.Integer,   ValueType.Integer, &IntNotEquals);
		AddOp("?",  ValueType.Integer,   ValueType.Lambda,  &If);
		AddOp(",",  ValueType.File,      ValueType.Integer, &Read);
		AddOp(",n", ValueType.File,      ValueType.Integer, &ReadLine);
		AddOp("+",  ValueType.String,    ValueType.String,  &AddString);
		AddOp("==", ValueType.String,    ValueType.String,  &EqualsString);
		AddOp("/=", ValueType.String,    ValueType.String,  &NotEqualsString);
		AddOp("@",  ValueType.Lambda,    ValueType.Lambda,  &While);
		AddOp("+",  ValueType.Array,     ValueType.Integer, &AddArray);
		AddOp("+",  ValueType.Array,     ValueType.String,  &AddArray);
		AddOp("+",  ValueType.Array,     ValueType.Lambda,  &AddArray);
		AddOp("+",  ValueType.Array,     ValueType.Array,   &AddArray);
		AddOp(":",  ValueType.Array,     ValueType.Integer, &ArrayIndex);
		AddOp("-",  ValueType.Array,     ValueType.Integer, &ArrayLength);
		AddOp(":=", ValueType.Reference, ValueType.Integer, &RefAssign);
		AddOp(":=", ValueType.Reference, ValueType.String,  &RefAssign);
		AddOp(":=", ValueType.Reference, ValueType.Lambda,  &RefAssign);
		AddOp(":=", ValueType.Reference, ValueType.Array,   &RefAssign);
		AddOp(":",  ValueType.Reference, ValueType.Integer, &DeRef);
		AddOp(":",  ValueType.Reference, ValueType.String,  &DeRef);
		AddOp(":",  ValueType.Reference, ValueType.Lambda,  &DeRef);
		AddOp(":",  ValueType.Reference, ValueType.Array,   &DeRef);
		AddOp("=>", ValueType.Array,     ValueType.Lambda,  &Function);
		AddOp("!",  ValueType.Function,  ValueType.Array,   &Call);
		AddOp("&&", ValueType.Lambda,    ValueType.Lambda,  &BoolAnd);
		AddOp("||", ValueType.Lambda,    ValueType.Lambda,  &BoolOr);

		// not strict operators
		AddOp(";", &Chain);
		AddOp("=", &Assign);

		// op meta
		SetOpMeta("=", false, true);
		SetOpMeta("=>", false, true);

		// builtin functions
		AddFunction("time",    &Time,    0);
		AddFunction("open",    &Open,    2);
		AddFunction("flush",   &Flush,   1);
		AddFunction("close",   &Close,   1);
		AddFunction("mkdir",   &Mkdir,   1);
		AddFunction("fexists", &FExists, 1);
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

	void AddFunction(string name, BuiltInFunc func, size_t argsLen) {
		auto value          = new FunctionValue();
		value.builtIn       = true;
		value.func          = func;
		value.params.length = argsLen;
		SetVariable(name, Variable(value));
	}

	bool VariableExists(string name) {
		return (name in scopes[0]) || (name in scopes[$ - 1]);
	}

	Variable GetVariable(string name) {
		if (name in scopes[$ - 1]) return scopes[$ - 1][name];
		return scopes[0][name];
	}

	Value* GetVariableRef(string name) {
		if (name in scopes[$ - 1]) return &scopes[$ - 1][name].value;
		return &scopes[0][name].value;
	}

	void SetVariable(string name) {
		if (name in scopes[0]) {
			scopes[0][name] = Variable(Value.Unit());
		}
		else {
			scopes[$ - 1][name] = Variable(Value.Unit());
		}
	}

	void SetVariable(string name, Variable value) {
		if (name in scopes[0]) {
			scopes[0][name] = value;
		}
		else {
			scopes[$ - 1][name] = value;
		}
	}

	void SetLocal(string name, Variable value) {
		scopes[$ - 1][name] = value;
	}

	void AddScope() {
		scopes ~= new Variable[string];
	}

	void RemoveScope() {
		scopes = scopes[0 .. $ - 1];
	}

	void AssertVariable(string name, ErrorInfo info) {
		if (!VariableExists(name)) {
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
					return GetVariable(node.name).value;
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
					ret.values ~= Evaluate(node2, evalVariables);
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

				Value ret;
				
				try {
					ret = op.func(left, right, this);
				}
				catch (OperatorException e) {
					ErrorBegin(node.info);
					stderr.writef("(%s) ", node.op);
					stderr.writeln(e.msg);
					exit(1);
				}

				return ret;
			}
			default: assert(0);
		}
	}
}
