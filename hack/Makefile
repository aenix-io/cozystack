.PHONY: test clean help

SCRIPT=./e2e.applications.sh
PRECHECKS=./pre-checks.sh

help:
	@echo "Usage: make {test|clean}"
	@echo "  test  - Run the end-to-end tests."
	@echo "  clean - Clean up resources."

test:
	@bash $(PRECHECKS) test
	@bash $(SCRIPT) test

clean:
	@bash $(SCRIPT) clean
