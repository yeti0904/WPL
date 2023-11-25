module wpl.lexer;

import std.stdio;
import std.string;
import std.algorithm;
import core.stdc.stdlib;
import wpl.error;
import wpl.language;

enum TokenType {
	Null,
	LParen,
	RParen,
	LCurly,
	RCurly,
	Operator,
	Integer,
	String,
	Identifier,
	End
}

struct Token {
	TokenType type;
	string    contents;
	ErrorInfo info;
}

class Lexer {
	Token[] tokens;
	string  reading;
	size_t  line;
	size_t  col;
	string  file;
	size_t  i;
	string  code;
	bool    inString;

	this() {
		
	}

	void Reset() {
		reading  = "";
		line     = 0;
		col      = 0;
		i        = 0;
		inString = false;
		tokens   = [];
	}

	ErrorInfo GetInfo() {
		return ErrorInfo(file, line, col);
	}

	void AddToken(TokenType type) {
		tokens  ~= Token(type, reading, ErrorInfo(file, line, col));
		reading  = "";
	}

	void AddReading() {
		if (reading.strip() == "") {
			reading = "";
			return;
		}
	
		if (reading.isNumeric()) {
			AddToken(TokenType.Integer);
		}
		else if (Language.operators.canFind(reading)) {
			AddToken(TokenType.Operator);
		}
		else {
			AddToken(TokenType.Identifier);
		}
	}

	void Lex() {
		for (i = 0; i < code.length; ++ i) {
			if (inString) {
				switch (code[i]) {
					case '"': {
						inString  = false;
						AddToken(TokenType.String);
						break;
					}
					case '\\': {
						++ i;
						switch (code[i]) {
							case 'n': reading ~= '\n'; break;
							case 'r': reading ~= '\r'; break;
							case 'e': reading ~= '\x1b'; break;
							default: {
								ErrorBegin(GetInfo());
								stderr.writefln("Unknown escape '%c'", code[i]);
								exit(1);
							}
						}
						break;
					}
					default: reading ~= code[i];
				}
			}
			else {
				switch (code[i]) {
					case ' ':
					case '\t':
					case '\n': {
						AddReading();
						break;
					}
					case '\r': break;
					case '"': {
						inString = true;
						break;
					}
					case '(': {
						AddReading();
						AddToken(TokenType.LParen);
						break;
					}
					case ')': {
						AddReading();
						AddToken(TokenType.RParen);
						break;
					}
					case '{': {
						AddReading();
						AddToken(TokenType.LCurly);
						break;
					}
					case '}': {
						AddReading();
						AddToken(TokenType.RCurly);
						break;
					}
					default: reading ~= code[i];
				}
			}
		}

		AddToken(TokenType.End);
	}
}
