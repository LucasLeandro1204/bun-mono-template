alias a := audit
alias b := build
alias c := check
alias cd := clean-dry-run
alias cs := changeset
alias css := changeset-status
alias d := dev
alias f := format
alias fc := format-check
alias i := install
alias l := lint
alias lf := lint-fix
alias o := outdated
alias s := start
alias t := test
alias tcov := test-coverage
alias tc := typecheck
alias vp := version-packages
alias ws := workspace

app_package := "@bun-mono-template/app"
changesets_cli := "./node_modules/@changesets/cli/bin.js"
clean_script := "scripts/clean.ts"

_run script:
  bun run {{script}}

_run_in package script *args:
  bun run --filter {{package}} {{script}} {{args}}

_changesets *args:
  bun {{changesets_cli}} {{args}}

_clean *args:
  bun run {{clean_script}} {{args}}

# List available project commands
[default]
[group('Meta')]
list:
  @just --list --unsorted

# Install workspace dependencies
[group('Workspace')]
install:
  bun install

# Run the app workspace in development mode
[group('Workspace')]
dev: (_run_in app_package "dev")

# Run the built app workspace
[group('Workspace')]
start: (_run_in app_package "start")

# Build all workspaces
[group('Workspace')]
build: (_run "build")

# Run a Bun script in a specific workspace
[group('Workspace')]
workspace package script *args:
  bun run --filter {{package}} {{script}} {{args}}

# Type-check all workspaces
[group('Quality')]
typecheck: (_run "typecheck")

# Run the test suite
[group('Quality')]
test: (_run "test")

# Run the test suite with coverage thresholds
[group('Quality')]
test-coverage: (_run "test:coverage")

# Audit dependencies for known vulnerabilities
[group('Quality')]
audit: (_run "audit")

# Show available dependency updates
[group('Quality')]
outdated: (_run "deps:outdated")

# Lint the repository
[group('Quality')]
lint: (_run "lint")

# Lint and apply automatic fixes
[group('Quality')]
lint-fix: (_run "lint:fix")

# Format the repository
[group('Quality')]
format: (_run "format")

# Check formatting without writing files
[group('Quality')]
format-check: (_run "format:check")

# Run the main validation suite
[group('Quality')]
check: format-check lint typecheck test-coverage build

# Remove install and build artifacts
[group('Maintenance')]
clean: (_clean)

# Preview cleanup targets without deleting files
[group('Maintenance')]
clean-dry-run: (_clean "--dry-run")

# Create a changeset for release notes and versioning
[group('Release')]
changeset: (_changesets)

# Show pending changesets and resulting package versions
[group('Release')]
changeset-status: (_changesets "status" "--verbose")

# Apply version bumps from queued changesets
[group('Release')]
version-packages: (_changesets "version")
