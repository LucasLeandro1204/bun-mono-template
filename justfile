alias b := build
alias c := check
alias d := dev
alias f := format
alias fc := format-check
alias i := install
alias l := lint
alias lf := lint-fix
alias s := start
alias tc := typecheck
alias t := test
alias ws := workspace

# List available project commands
[default]
list:
  @just --list --unsorted

# Install workspace dependencies
install:
  bun install

# Run the app workspace in development mode
dev:
  bun run dev

# Run the built app workspace
start:
  bun run start

# Build all workspaces
build:
  bun run build

# Type-check all workspaces
typecheck:
  bun run typecheck

# Run the test suite
test:
  bun run test

# Lint the repository
lint:
  bun run lint

# Lint and apply automatic fixes
lint-fix:
  bun run lint:fix

# Format the repository
format:
  bun run format

# Check formatting without writing files
format-check:
  bun run format:check

# Run the main validation suite
check: format-check lint typecheck test build

# Remove install and build artifacts
clean:
  rm -rf node_modules coverage packages/*/dist packages/*/*.tsbuildinfo

# Run a Bun script in a specific workspace
workspace package +args:
  bun run --filter {{package}} {{args}}
