module wpl.app;

import std.file;
import std.stdio;
import std.range;
import wpl.lexer;
import wpl.parser;
import wpl.exception;
import wpl.interpreter;

int main(string[] args) {
	string   inFile;
	bool     debugLexer = false;
	string[] programArgs;
	
	auto lexer       = new Lexer();
	auto parser      = new Parser();
	auto interpreter = new Interpreter();

	for (size_t i = 1; i < args.length; ++ i) {
		if (inFile == "") {
			if (args[i][0] == '-') {
				switch (args[i]) {
					default: {
						stderr.writefln("Invalid flag ''", args[i]);
						return 1;
					}
				}
			}
			else {
				inFile       = args[i];
				programArgs ~= args[i];
			}
		}
		else {
			programArgs ~= args[i];
		}
	}

	interpreter.AddArgs(programArgs);

	if (inFile == "") {
		writeln("WPL REPL");
		while (true) {
			writef("> ");
			string code = readln();

			// reset states
			lexer.Reset();
			parser.Reset();
			
			lexer.code = code;
			lexer.file = "<stdin>";

			try {
				lexer.Lex();
			}
			catch (FatalException) {
				continue;
			}

			if (lexer.tokens[0].type == TokenType.End) {
				continue;
			}

			if (debugLexer) {
				foreach (ref token ; lexer.tokens) {
					writeln(token);
				}
			}
		
			parser.tokens = lexer.tokens;


			try {
				auto program = parser.ParseOperator();
				writeln(interpreter.Evaluate(program, true));
			}
			catch (FatalException) {}
		}
	}
	else {
		interpreter.thisFile ~= inFile;
		lexer.file            = inFile;
		
		try {
			lexer.code = readText(inFile);
		}
		catch (FileException e) {
			stderr.writefln("Error: %s", e.msg);
			return 1;
		}

		try {
			lexer.Lex();
		}
		catch (FatalException) {
			return 1;
		}

		if (lexer.tokens[0].type == TokenType.End) {
			return 0;
		}
		
		parser.tokens = lexer.tokens;

		try {
			interpreter.Evaluate(parser.ParseOperator(), true);
		}
		catch (FatalException) {
			return 1;
		}
	}

	return 0;
}
