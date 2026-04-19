# bun-mono-template

Production-ready Bun monorepo template using Bun workspaces, TypeScript project references, and a single local/CI quality gate.

## Requirements

- Install Bun `>=1.3.0`: https://bun.com/docs/pm/cli/install
- Install Just (optional command runner): https://just.systems/man/en/

## Quick Start

With Bun directly:

```bash
bun install
bun run check
bun run dev
```

With `just` convenience recipes:

```bash
just install
just check
just dev
```

Build and run the production bundle:

```bash
bun run build
bun run start
```

Set `APP_NAME` to customize the runtime greeting:

```bash
APP_NAME="Production" bun run dev
```

## Quality Gates

- `bun run format:check` checks repository formatting.
- `bun run lint` validates code quality with ESLint.
- `bun run typecheck` verifies TypeScript project references.
- `bun run test` runs the Bun test suite while ignoring compiled `dist/` output.
- `bun run build` emits production `dist/` artifacts for each workspace.
- `bun run check` runs the same full validation gate used by CI.

Equivalent `just` recipes are available for the main workflows, including `just check`, `just test`, and `just start`.

## Workspace Layout

- `packages/shared` - internal shared library
- `packages/app` - application package consuming `@bun-mono-template/shared`

## Production Notes

- Workspace packages resolve to source through Bun's `bun` export condition during development, while external consumers receive compiled `dist/` artifacts.
- The app entrypoint is import-safe and testable, so importing it in tooling or tests does not trigger unexpected console output.
- Continuous integration runs `bun run check` on every pull request and on pushes to `main`.
