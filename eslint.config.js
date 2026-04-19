import js from '@eslint/js';
import eslintConfigPrettier from 'eslint-config-prettier';
import perfectionist from 'eslint-plugin-perfectionist';
import globals from 'globals';
import tseslint from 'typescript-eslint';

const packages = ['@bun-mono-template/app', '@bun-mono-template/shared', '#root'];
const internalGlobalPattern = `^(${packages
  .map((name) => name.replaceAll('/', '\\/').replaceAll('@', '\\@'))
  .join('|')})$`;

export default tseslint.config(
  {
    name: 'bun-mono-template/ignore',
    ignores: ['**/.adminjs/**', '**/coverage/**', '**/dist/**', '**/node_modules/**', '**/*.d.ts', '**/*.tsbuildinfo'],
  },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    name: 'bun-mono-template/language-options',
    files: ['**/*.{js,mjs,cjs,jsx,ts,mts,cts,tsx}'],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.node,
        ...globals.bunBuiltin,
      },
    },
  },
  {
    name: 'bun-mono-template/perfectionist',
    files: ['**/*.{js,mjs,cjs,jsx,ts,mts,cts,tsx}'],
    plugins: {
      perfectionist,
    },
    rules: {
      'perfectionist/sort-exports': ['error'],
      'perfectionist/sort-imports': [
        'error',
        {
          customGroups: [
            {
              elementNamePattern: internalGlobalPattern,
              groupName: 'internal-global',
            },
          ],
          groups: [
            'type',
            'builtin',
            'external',
            'internal-global',
            'internal',
            ['parent', 'sibling', 'index'],
            'unknown',
          ],
          internalPattern: ['^@bun-mono-template/.*', '^#.*'],
          newlinesBetween: 0,
        },
      ],
      'perfectionist/sort-named-exports': ['error'],
      'perfectionist/sort-named-imports': ['error'],
    },
  },
  eslintConfigPrettier,
);
