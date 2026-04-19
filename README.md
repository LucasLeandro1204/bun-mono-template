# bun-mono-template

Bun monorepo template using Bun workspaces and TypeScript references.

## Requirements

- Install Bun (latest): https://bun.com/docs/pm/cli/install

## Setup

1. Install Bun packages

```bash
bun install
```

2. Run all workspace builds

```bash
bun run build
```

3. Type-check all workspaces

```bash
bun run typecheck
```

4. Run the app package in dev mode

```bash
bun run dev
```

## Workspace layout

- `packages/shared` - internal shared library
- `packages/app` - application package consuming `@bun-mono-template/shared`
