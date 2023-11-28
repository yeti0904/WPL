module wpl.exception;

class FatalException : Exception {
	this() {
		super("", "", 0);
	}
}

void Fatal() {
	throw new FatalException();
}
