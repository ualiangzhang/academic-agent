SHELL:=/bin/bash
.PHONY: bootstrap cdk-bootstrap deploy

bootstrap:
	@echo "Bootstrapping dev environment"
	@test -d .venv || python3.12 -m venv .venv
	@. .venv/bin/activate && python -V
	@command -v poetry >/dev/null 2>&1 && echo "Poetry OK" || pip install poetry
	@poetry --version
	@poetry config virtualenvs.create false || true
	@if [ -f pyproject.toml ]; then poetry install --no-root; else echo "No pyproject.toml - skipping poetry install"; fi

# CDK bootstrap helper (requires AWS_PROFILE and AWS_REGION).
# Derives ACCOUNT_ID via STS. Skips if credentials missing.
cdk-bootstrap:
	@if ! command -v aws >/dev/null; then echo "aws cli not installed"; exit 1; fi
	@if [ -z "$(AWS_PROFILE)" ]; then echo "AWS_PROFILE not set. export AWS_PROFILE=<profile>"; exit 1; fi
	@if [ -z "$(AWS_REGION)" ]; then echo "AWS_REGION not set. export AWS_REGION=<region>"; exit 1; fi
	@echo "Using profile $(AWS_PROFILE) and region $(AWS_REGION)"
	@ACCOUNT_ID=$$(aws sts get-caller-identity --query Account --output text --profile "$(AWS_PROFILE)" 2>/dev/null) && \
	if [ -z "$$ACCOUNT_ID" ]; then echo "Unable to get AWS account (check credentials)"; exit 1; fi; \
	echo "Bootstrapping CDK for $$ACCOUNT_ID in $(AWS_REGION)"; \
	cdk bootstrap aws://$$ACCOUNT_ID/$(AWS_REGION) --profile "$(AWS_PROFILE)"

# Safe deploy: requires a CDK app (cdk.json). Skips gracefully if missing.
deploy:
	@if [ ! -f cdk.json ]; then echo "No CDK app (cdk.json missing). Skipping deploy."; exit 0; fi
	@if [ -z "$(AWS_PROFILE)" ]; then echo "AWS_PROFILE not set. export AWS_PROFILE=<profile>"; exit 1; fi
	@if [ -z "$(AWS_REGION)" ]; then echo "AWS_REGION not set. export AWS_REGION=<region>"; exit 1; fi
	@echo "Deploying stage $(STAGE) to $(AWS_REGION) with profile $(AWS_PROFILE)"
	cdk deploy --all --require-approval never --profile "$(AWS_PROFILE)"
