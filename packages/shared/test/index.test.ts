import { describe, expect, it } from 'bun:test';
import { greet, normalizeGreetingName } from '../src/index';

describe('normalizeGreetingName', () => {
  it('trims surrounding whitespace', () => {
    expect(normalizeGreetingName('  Bun  ')).toBe('Bun');
  });

  it('rejects empty names', () => {
    expect(() => normalizeGreetingName('   ')).toThrow(
      'Greeting name must contain at least one non-whitespace character.',
    );
  });
});

describe('greet', () => {
  it('formats a stable greeting', () => {
    expect(greet('  Bun  ')).toBe('Hello, Bun!');
  });
});
