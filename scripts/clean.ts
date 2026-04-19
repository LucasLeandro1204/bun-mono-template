import { readdir, rm } from 'node:fs/promises';
import { join } from 'node:path';

const cwd = process.cwd();
const dryRun = Bun.argv.includes('--dry-run');

async function listPackageDirectories(): Promise<string[]> {
  try {
    const entries = await readdir(join(cwd, 'packages'), { withFileTypes: true });

    return entries.filter((entry) => entry.isDirectory()).map((entry) => entry.name);
  } catch {
    return [];
  }
}

function pruneNestedTargets(targets: string[]): string[] {
  const normalizedTargets = [...new Set(targets.map((target) => target.replaceAll('\\', '/')))].sort();

  return normalizedTargets.filter((target, index) => {
    return !normalizedTargets.some((candidate, candidateIndex) => {
      return candidateIndex !== index && target.startsWith(`${candidate}/`);
    });
  });
}

async function collectTargets(): Promise<string[]> {
  const packageDirectories = await listPackageDirectories();
  const staticTargets = ['coverage', 'node_modules'];
  const packageTargets = packageDirectories.flatMap((directory) => [
    `packages/${directory}/dist`,
    `packages/${directory}/tsconfig.tsbuildinfo`,
  ]);
  const discoveredTsBuildInfoTargets: string[] = [];

  for await (const match of new Bun.Glob('packages/*/**/*.tsbuildinfo').scan({ cwd })) {
    discoveredTsBuildInfoTargets.push(match);
  }

  return pruneNestedTargets([...staticTargets, ...packageTargets, ...discoveredTsBuildInfoTargets]);
}

const targets = await collectTargets();

if (targets.length === 0) {
  console.log('Nothing to clean.');
  process.exit(0);
}

if (dryRun) {
  console.log(`Dry run: would remove ${targets.length} path(s).`);

  for (const target of targets) {
    console.log(`- ${target}`);
  }

  process.exit(0);
}

await Promise.all(
  targets.map(async (target) => {
    await rm(join(cwd, target), {
      force: true,
      recursive: true,
    });
  }),
);

console.log(`Removed ${targets.length} path(s).`);

for (const target of targets) {
  console.log(`- ${target}`);
}
