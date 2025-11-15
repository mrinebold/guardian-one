/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'aviation-blue': '#1e40af',
        'aviation-red': '#dc2626',
        'aviation-yellow': '#fbbf24',
        'aviation-green': '#16a34a',
        'star-wars-yellow': '#feda4a',
      },
      fontFamily: {
        'star-wars': ['"News Cycle"', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
