# Contributing

Thanks for contributing to `bun-mono-template`.

## Prerequisites

- Bun `>=1.3.12`
- Just (optional) for shorthand commands

The repository pins Bun via `packageManager` in `package.json`, and CI installs Bun from that version.

## First-Time Setup

With Bun directly:

```bash
bun install
bun run check
```

With `just`:

```bash
just install
just check
```

## Daily Workflow

- `bun run dev` starts the app workspace in watch mode.
- `bun run test` runs the full test suite.
- `bun run lint` runs ESLint.
- `bun run typecheck` verifies source and test TypeScript without writing build artifacts.
- `bun run test:coverage` runs Bun coverage with the thresholds in `bunfig.toml`.
- `bun run build` emits `dist/` artifacts for each workspace.
- `bun run check` runs the same validation gate as CI, including coverage thresholds.

`format:check`, `lint`, `typecheck`, and `test` validate without intentionally modifying source files. `build` is the command that emits declaration and runtime artifacts.

## Maintenance Commands

- `bun run clean` removes install and build artifacts.
- `bun run clean:dry-run` previews what would be removed.
- `bun run audit` checks dependencies for known vulnerabilities.
- `bun run deps:outdated` checks for available dependency updates.

Equivalent `just` recipes are available for each of the commands above.

## Workspace Structure

- `packages/shared` contains reusable library code.
- `packages/app` contains the runnable application.
- `src/` is used for source code inside each workspace.
- `test/` is used for workspace-local tests.
- `dist/` is generated output and should not be edited by hand.

## Release Notes and Versioning

This repository uses Changesets for release planning:

```bash
bun run changeset
bun run changeset:status
bun run version-packages
```

If you are using this repository as a template for a new project, update the following before publishing releases:

- package names, filtered scripts, and workspace dependencies under `package.json` and `packages/*/package.json`
- package selectors in `justfile`
- path aliases in `tsconfig.base.json`
- internal package names and import patterns in `eslint.config.js`
- the GitHub repository reference in `.changeset/config.json`
- any README text that still references `bun-mono-template`

Changesets commands prepare local version and changelog updates. The release dry-run workflow validates packaging and release status, but it does not publish packages.

## CI Expectations

GitHub Actions runs:

```bash
bun install --frozen-lockfile
bun run check
bun run start
bun run changeset:status
```

CI also dry-runs packing each workspace package. Before opening a pull request, make sure those commands pass locally.
