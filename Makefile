SHELL:=/bin/bash
.PHONY: bootstrap

bootstrap:
	@echo "Bootstrapping dev environment"
	@test -d .venv || python3.12 -m venv .venv
	@. .venv/bin/activate && python -V
	@command -v poetry >/dev/null 2>&1 && echo "Poetry OK" || pip install poetry
	@poetry --version
	@poetry config virtualenvs.create false || true
	@if [ -f pyproject.toml ]; then poetry install --no-root; else echo "No pyproject.toml - skipping poetry install"; fi
