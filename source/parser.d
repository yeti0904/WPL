module wpl.parser;

import std.conv;
import std.stdio;
import std.format;
import core.stdc.stdlib;
import wpl.error;
import wpl.lexer;
import wpl.exception;

enum NodeType {
	Null,
	Integer,
	String,
	Identifier,
	Expression,
	Lambda,
	Array
}

class Node {
	NodeType  type;
	ErrorInfo info;
}

class IntegerNode : Node {
	long value;

	this(ErrorInfo pinfo) {
		type = NodeType.Integer;
		info = pinfo;
	}

	override string toString() {
		return text(value);
	}
}

class StringNode : Node {
	string value;

	this(ErrorInfo pinfo) {
		type = NodeType.String;
		info = pinfo;
	}

	override string toString() {
		return format("\"%s\"", value);
	}
}

class IdentifierNode : Node {
	string name;

	this(ErrorInfo pinfo) {
		type = NodeType.Identifier;
		info = pinfo;
	}

	override string toString() {
		return name;
	}
}

class ExpressionNode : Node {
	Node   left;
	string op;
	Node   right;

	this(ErrorInfo pinfo) {
		type = NodeType.Expression;
		info = pinfo;
	}

	override string toString() {
		return format("(%s %s %s)", left, op, right);
	}
}

class LambdaNode : Node {
	Node expr;

	this(ErrorInfo pinfo) {
		type = NodeType.Lambda;
		info = pinfo;
	}

	override string toString() {
		return format("{%s}", expr);
	}
}

class ArrayNode : Node {
	Node[] values;

	this(ErrorInfo pinfo) {
		type = NodeType.Array;
		info = pinfo;
	}

	override string toString() {
		string ret = "[";

		foreach (ref val ; values) {
			ret ~= format("%s ", val);
		}

		return ret ~ ']';
	}
}

class Parser {
	Token[] tokens;
	size_t  i;

	this() {
		
	}

	void Reset() {
		i = 0;
	}

	void Next() {
		++ i;

		if (i >= tokens.length) {
			ErrorBegin(tokens[$ - 1].info);
			stderr.writeln("Unexpected EOF");
			Fatal();
		}
	}

	void Expect(TokenType type) {
		if (tokens[i].type != type) {
			ErrorBegin(tokens[i].info);
			stderr.writefln("Expected %s, got %s\n", type, tokens[i].type);
			Fatal();
		}
	}

	ErrorInfo GetInfo() {
		return tokens[i].info;
	}

	Node ParseAtom() {
		switch (tokens[i].type) {
			case TokenType.LParen: {
				Next();
				auto ret = ParseOperator();
				Expect(TokenType.RParen);
				++ i;
				return ret;
			}
			case TokenType.LCurly: {
				Next();
				auto expr = ParseOperator();
				auto ret  = new LambdaNode(GetInfo());
				ret.expr  = expr;
				Expect(TokenType.RCurly);
				++ i;
				return ret;
			}
			case TokenType.LSquare: {
				Next();
				auto ret = new ArrayNode(GetInfo());

				while (tokens[i].type != TokenType.RSquare) {
					ret.values ~= ParseAtom();
				}
				Next();
				return ret;
			}
			case TokenType.Integer: {
				auto ret  = new IntegerNode(GetInfo());
				//writefln("Parsing %s", tokens[i].contents);
				ret.value = parse!long(tokens[i].contents);
				++ i;
				return ret;
			}
			case TokenType.String: {
				auto ret  = new StringNode(GetInfo());
				ret.value = tokens[i].contents;
				++ i;
				return ret;
			}
			case TokenType.Identifier: {
				auto ret  = new IdentifierNode(GetInfo());
				ret.name = tokens[i].contents;
				++ i;
				return ret;
			}
			default: {
				ErrorBegin(tokens[i].info);
				stderr.writefln("Unexpected %s", tokens[i].type);
				Fatal();
			}
		}

		assert(0);
	}

	Node ParseOperator() {
		auto left = ParseAtom();

		while (tokens[i].type == TokenType.Operator) {
			auto expr = new ExpressionNode(GetInfo());
			expr.left = left;
			expr.op   = tokens[i].contents;
			Next();
			expr.right = ParseAtom();
			left = expr;
		}

		return left;
	}
}
