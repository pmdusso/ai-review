.PHONY: test lint install install-templates help

help:
	@echo "Targets: test lint install install-templates"

test:
	bats tests/unit tests/integration

lint:
	shellcheck ai-review scripts/*.sh

install:
	./scripts/install.sh

install-templates:
	./scripts/install-templates.sh
