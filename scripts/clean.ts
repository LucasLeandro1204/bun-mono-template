import { readdir, readFile, rm, stat } from 'node:fs/promises';
import { dirname, join, relative, resolve, sep } from 'node:path';
import { fileURLToPath, argv, Glob } from 'bun';

const scriptPath = fileURLToPath(import.meta.url);
const repoRoot = resolve(dirname(scriptPath), '..');
const dryRun = argv.includes('--dry-run');

type PackageJson = {
  private?: boolean;
  scripts?: Record<string, string>;
  engines?: Record<string, string>;
};

async function pathIsDirectory(path: string): Promise<boolean> {
  try {
    return (await stat(path)).isDirectory();
  } catch {
    return false;
  }
}

async function pathIsFile(path: string): Promise<boolean> {
  try {
    return (await stat(path)).isFile();
  } catch {
    return false;
  }
}

async function assertRepoRoot(): Promise<void> {
  const packageJsonPath = join(repoRoot, 'package.json');
  const packageJson = JSON.parse(await readFile(packageJsonPath, 'utf8')) as PackageJson;
  const expectedScriptPath = join(repoRoot, 'scripts', 'clean.ts');

  const markers = [
    packageJson.private === true,
    packageJson?.engines?.bun,
    typeof packageJson.scripts?.clean === 'string' && packageJson.scripts.clean.includes('scripts/clean.ts'),
    resolve(scriptPath) === resolve(expectedScriptPath),
    await pathIsFile(join(repoRoot, 'bun.lock')),
    await pathIsDirectory(join(repoRoot, 'packages')),
  ];

  if (markers.every(Boolean)) {
    return;
  }

  throw new Error(`Refusing to clean because ${repoRoot} does not look like the repository root.`);
}

async function listPackageDirectories(): Promise<string[]> {
  try {
    const entries = await readdir(join(repoRoot, 'packages'), { withFileTypes: true });

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

  for await (const match of new Glob('packages/*/**/*.tsbuildinfo').scan({ cwd: repoRoot })) {
    discoveredTsBuildInfoTargets.push(match);
  }

  return pruneNestedTargets([...staticTargets, ...packageTargets, ...discoveredTsBuildInfoTargets]);
}

function resolveTarget(target: string): string {
  const targetPath = resolve(repoRoot, target);
  const relativeTarget = relative(repoRoot, targetPath);

  if (relativeTarget === '' || relativeTarget === '..' || relativeTarget.startsWith(`..${sep}`)) {
    throw new Error(`Refusing to clean path outside repository root: ${target}`);
  }

  return targetPath;
}

await assertRepoRoot();

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
    await rm(resolveTarget(target), {
      force: true,
      recursive: true,
    });
  }),
);

console.log(`Removed ${targets.length} path(s).`);

for (const target of targets) {
  console.log(`- ${target}`);
}
