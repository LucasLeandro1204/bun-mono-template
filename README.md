# bun-mono-template

Bun monorepo template using Bun workspaces and TypeScript references.

## Requirements

- Install Bun (latest): https://bun.com/docs/pm/cli/install
- Install Just: https://just.systems/man/en/

## Setup

1. Install Bun packages

```bash
just install
```

2. Run all workspace builds

```bash
just build
```

3. Type-check all workspaces

```bash
just typecheck
```

4. Run the app package in dev mode

```bash
just dev
```

## Common recipes

```bash
just          # list available recipes
just check    # format check, lint, typecheck, and build
just lint
just lint-fix
just format
just clean
```

Run a script inside a specific workspace:

```bash
just workspace @bun-mono-template/app dev
just workspace @bun-mono-template/shared build
```

## Workspace layout

- `packages/shared` - internal shared library
- `packages/app` - application package consuming `@bun-mono-template/shared`
