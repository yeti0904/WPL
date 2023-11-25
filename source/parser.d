module wpl.parser;

import std.conv;
import std.stdio;
import std.format;
import core.stdc.stdlib;
import wpl.error;
import wpl.lexer;

enum NodeType {
	Null,
	Integer,
	String,
	Identifier,
	Expression,
	Lambda
}

class Node {
	NodeType  type;
	ErrorInfo info;
}

class IntegerNode : Node {
	long value;

	this() {
		type = NodeType.Integer;
	}

	override string toString() {
		return text(value);
	}
}

class StringNode : Node {
	string value;

	this() {
		type = NodeType.String;
	}

	override string toString() {
		return format("\"%s\"", value);
	}
}

class IdentifierNode : Node {
	string name;

	this() {
		type = NodeType.Identifier;
	}

	override string toString() {
		return name;
	}
}

class ExpressionNode : Node {
	Node   left;
	string op;
	Node   right;

	this() {
		type = NodeType.Expression;
	}

	override string toString() {
		return format("(%s %s %s)", left, op, right);
	}
}

class LambdaNode : Node {
	Node expr;

	this() {
		type = NodeType.Lambda;
	}

	override string toString() {
		return format("{%s}", expr);
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
			exit(1);
		}
	}

	void Expect(TokenType type) {
		if (tokens[i].type != type) {
			ErrorBegin(tokens[i].info);
			stderr.writefln("Expected %s, got %s\n", type, tokens[i].type);
			exit(1);
		}
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
				auto ret  = new LambdaNode();
				ret.expr  = expr;
				Expect(TokenType.RCurly);
				++ i;
				return ret;
			}
			case TokenType.Integer: {
				auto ret  = new IntegerNode();
				//writefln("Parsing %s", tokens[i].contents);
				ret.value = parse!long(tokens[i].contents);
				++ i;
				return ret;
			}
			case TokenType.String: {
				auto ret  = new StringNode();
				ret.value = tokens[i].contents;
				++ i;
				return ret;
			}
			case TokenType.Identifier: {
				auto ret  = new IdentifierNode();
				ret.name = tokens[i].contents;
				++ i;
				return ret;
			}
			default: {
				ErrorBegin(tokens[i].info);
				stderr.writefln("Unexpected %s", tokens[i].type);
				exit(1);
			}
		}
	}

	Node ParseOperator() {
		auto left = ParseAtom();

		while (tokens[i].type == TokenType.Operator) {
			auto expr = new ExpressionNode();
			expr.left = left;
			expr.op   = tokens[i].contents;
			Next();
			expr.right = ParseAtom();
			left = expr;
		}

		return left;
	}
}
