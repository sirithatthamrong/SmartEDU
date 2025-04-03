const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
    "./app/assets/stylesheets/**/*.css"
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("daisyui"),
  ],
  daisyui: {
    themes: [
      "light",
      "pastel",
      {
        mytheme: {
          // Use fallback colors to avoid Tailwind build errors
          "primary": "#000000",
          "primary-content": "#f3faff",
          "secondary": "#000000",
          "secondary-content": "#f1fbfb",
          "accent": "#000000",
          "accent-content": "#00182a",
          "base-100": "#ffffff",
          "base-200": "#f8f8f8",
          "base-300": "#f0f0f0",
          "base-500": "#d0d0d0",
          "base-content": "#00182a",
          "neutral": "#6b8a9e",
          "neutral-content": "#f3faff",
          "info": "#3ABFF8",
          "info-content": "#f3fbff",
          "success": "#36D399",
          "success-content": "#f3fbf6",
          "warning": "#ffd45e",
          "warning-content": "#221300",
          "error": "#F87272",
          "error-content": "#fff6f4",
          "radius-selector": "1rem",
          "radius-field": "0.25rem",
          "radius-box": "0.5rem",
          "size-selector": "0.25rem",
          "size-field": "0.25rem",
          "border": "1px",
          "depth": "1",
          "noise": "0",
        },
      },
    ],
    theme: "pastel",
  },
};
