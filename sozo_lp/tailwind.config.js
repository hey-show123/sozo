/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#6366F1",
        secondary: "#8B5CF6",
        accent: "#F59E0B",
        background: "#FEFBFF",
        surface: "#FFFFFF",
        pop: {
          pink: "#EC4899",
          mint: "#06D6A0",
          yellow: "#FACC15",
          blue: "#3B82F6",
          purple: "#8B5CF6",
          orange: "#F97316",
          red: "#EF4444",
          green: "#22C55E",
        }
      },
      fontFamily: {
        sans: ['"M PLUS Rounded 1c"', 'sans-serif'],
      }
    },
  },
  plugins: [],
}
