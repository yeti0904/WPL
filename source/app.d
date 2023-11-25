module wpl.app;

import std.stdio;
import wpl.lexer;
import wpl.parser;
import wpl.interpreter;

void main() {
	writeln("WPL REPL");
	
	auto lexer       = new Lexer();
	auto parser      = new Parser();
	auto interpreter = new Interpreter();
	bool debugLexer  = false;

	while (true) {
		writef("> ");
		string code = readln();

		// reset states
		lexer.Reset();
		parser.Reset();
		
		lexer.code = code;
		lexer.Lex();

		if (debugLexer) {
			foreach (ref token ; lexer.tokens) {
				writeln(token);
			}
		}
	
		parser.tokens = lexer.tokens;

		auto program = parser.ParseOperator();
		writeln(interpreter.Evaluate(program, true));
	}
}
