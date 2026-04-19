import { describe, expect, it } from 'bun:test';
import { formatGreeting, resolveAppName, runApp } from '../src/index';

describe('resolveAppName', () => {
  it('prefers APP_NAME when it is configured', () => {
    expect(resolveAppName({ APP_NAME: 'Release' })).toBe('Release');
  });

  it('falls back to the default app name when APP_NAME is blank', () => {
    expect(resolveAppName({ APP_NAME: '   ' })).toBe('Bun');
  });
});

describe('formatGreeting', () => {
  it('formats the resolved greeting', () => {
    expect(formatGreeting('  Bun  ')).toBe('Hello, Bun!');
  });
});

describe('runApp', () => {
  it('writes and returns the final greeting', () => {
    const writes: string[] = [];

    const message = runApp({
      name: 'Template',
      write: (value) => {
        writes.push(value);
      },
    });

    expect(message).toBe('Hello, Template!');
    expect(writes).toEqual(['Hello, Template!']);
  });
});
