import { greet } from '@bun-mono-template/shared';

const DEFAULT_APP_NAME = 'Bun';

export type AppEnvironment = Readonly<Record<string, string | undefined>>;

export interface RunAppOptions {
  name?: string;
  write?: (message: string) => void;
}

export function resolveAppName(environment: AppEnvironment = process.env): string {
  const configuredName = environment.APP_NAME?.trim();

  return configuredName && configuredName.length > 0 ? configuredName : DEFAULT_APP_NAME;
}

export function formatGreeting(name = resolveAppName()): string {
  return greet(name);
}

export function runApp(options: RunAppOptions = {}): string {
  const message = formatGreeting(options.name ?? resolveAppName());

  (options.write ?? console.log)(message);

  return message;
}

if (import.meta.main) {
  runApp();
}
