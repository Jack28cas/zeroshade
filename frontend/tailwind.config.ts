import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          light: '#a694ff',
          main: '#6365ff',
          pale: '#dfdfff',
        },
      },
      fontFamily: {
        sans: ['TT Firs Neue', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
export default config

