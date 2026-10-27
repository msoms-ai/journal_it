import type { Config } from 'tailwindcss';

const config: Config = {
  darkMode: 'class',
  content: [
    './src/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        canvas: 'var(--bg-canvas)',
        surface: 'var(--bg-surface)',
        subtle: 'var(--bg-subtle)',
        ink: {
          primary: 'var(--text-primary)',
          secondary: 'var(--text-secondary)',
        },
        editorial: {
          crimson: 'var(--accent-crimson)',
          navy: 'var(--accent-byline)',
          rule: 'var(--border-rule)',
        },
      },
      fontFamily: {
        sans: ['Dubai', 'sans-serif'],
        headline: ['Dubai', 'sans-serif'],
        body: ['Dubai', 'sans-serif'],
      },
    },
  },
  plugins: [],
};

export default config;
