module wpl.app;

import std.file;
import std.stdio;
import std.range;
import wpl.lexer;
import wpl.parser;
import wpl.interpreter;

int main(string[] args) {
	string inFile;
	bool   debugLexer = false;
	
	auto lexer       = new Lexer();
	auto parser      = new Parser();
	auto interpreter = new Interpreter();

	for (size_t i = 1; i < args.length; ++ i) {
		if (args[i][0] == '-') {
			switch (args[i]) {
				default: {
					stderr.writefln("Invalid flag ''", args[i]);
					return 1;
				}
			}
		}
		else {
			inFile = args[i];
		}
	}

	if (inFile == "") {
		writeln("WPL REPL");
		while (true) {
			writef("> ");
			string code = readln();

			// reset states
			lexer.Reset();
			parser.Reset();
			
			lexer.code = code;
			lexer.Lex();

			if (lexer.tokens[0].type == TokenType.End) {
				continue;
			}

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
	else {
		lexer.file = inFile;
		
		try {
			lexer.code = readText(inFile);
		}
		catch (FileException e) {
			stderr.writefln("Error: %s", e.msg);
			return 1;
		}

		lexer.Lex();

		if (lexer.tokens[0].type == TokenType.End) {
			return 0;
		}
		
		parser.tokens = lexer.tokens;

		interpreter.Evaluate(parser.ParseOperator(), true);
	}

	return 0;
}
