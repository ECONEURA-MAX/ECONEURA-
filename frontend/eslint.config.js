// ESLint v9 config for TypeScript + React
export default [
  {
    ignores: ['dist', 'node_modules', '*.config.js', '*.config.ts', 'build-for-vercel.cjs']
  },
  {
    files: ['**/*.{js,jsx,ts,tsx}'],
    languageOptions: {
      ecmaVersion: 2020,
      sourceType: 'module',
      parserOptions: {
        ecmaFeatures: {
          jsx: true
        }
      }
    },
    rules: {
      'no-unused-vars': 'warn',
      'no-console': 'off'
    }
  }
];
