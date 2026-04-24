# bun-mono-template

Production-ready Bun monorepo template using Bun workspaces, TypeScript project references, and a single local/CI quality gate.

See [CONTRIBUTING.md](./CONTRIBUTING.md) for the full contributor workflow, dependency maintenance commands, and release notes/versioning steps.

## Requirements

- Install Bun `>=1.3.12`: https://bun.com/docs/pm/cli/install
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

- `bun run format:check` checks repository formatting without writing files.
- `bun run lint` validates code quality with ESLint.
- `bun run typecheck` verifies source and test TypeScript without writing build artifacts.
- `bun run test` runs the Bun test suite while ignoring compiled `dist/` output.
- `bun run test:coverage` runs the test suite with Bun coverage reporting and the thresholds in `bunfig.toml`.
- `bun run build` emits production `dist/` artifacts for each workspace.
- `bun run check` runs the same full validation gate used by CI, including coverage thresholds.

Equivalent `just` recipes are available for the main workflows, including `just check`, `just test-coverage`, and `just start`.

## Developer Maintenance

- `bun run clean` removes install and build artifacts across the workspace.
- `bun run clean:dry-run` previews cleanup targets without deleting files.
- `bun run audit` checks for known dependency vulnerabilities.
- `bun run deps:outdated` lists available dependency updates.

Equivalent `just` recipes are available as `just clean`, `just audit`, and `just outdated`.

## Workspace Layout

- `packages/shared` - internal shared library
- `packages/app` - application package consuming `@bun-mono-template/shared`

Workspace packages export compiled `dist/` artifacts for Bun and standard ESM consumers. Local TypeScript development resolves shared package source through `tsconfig.base.json` paths, so run `bun run build` before consuming packages outside the workspace.

## Detaching the Template

Use `.agents/skills/detach-template/scripts/detach-template.sh` to rename template identifiers and reinitialize Git history. Before publishing a detached project, verify these references:

- `package.json` and `packages/*/package.json` package names, filtered scripts, and workspace dependencies
- `justfile` package selectors such as `app_package`
- `tsconfig.base.json` path aliases
- `eslint.config.js` internal package names and import patterns
- `.changeset/config.json` GitHub repository slug
- README and contribution text that still references this template

## Release Notes and Versioning

The repository includes [Changesets](https://github.com/changesets/changesets) configuration for release notes and package versioning:

- `bun run changeset` creates a new changeset entry.
- `bun run changeset:status` previews pending version bumps.
- `bun run version-packages` applies queued version updates locally.

If you use this repository as a template, remember to update package names and the GitHub repository reference in `.changeset/config.json`.

The manual release dry-run workflow validates the full gate, smokes the built app, dry-runs package packing, and checks Changesets status. It does not publish packages.

## Production Notes

- The app entrypoint is import-safe and testable, so importing it in tooling or tests does not trigger unexpected console output.
- Continuous integration runs `bun run check`, smokes the production entrypoint, dry-runs workspace package packing, and checks Changesets status on every pull request and on pushes to `main`.
