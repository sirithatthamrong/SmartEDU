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
    themes: [ "pastel",
      {
        mytheme: {
          "primary": "var(--primary)",
          "primary-content": "#f3faff",
          "secondary": "var(--secondary)",
          "secondary-content": "#f1fbfb",
          "accent": "var(--accent)",
          "accent-content": "#00182a",
          "base-100": "var(--base-100)",
          "base-200": "var(--base-200)",
          "base-300": "var(--base-300)",
          "base-500": "var(--base-500)",
          "base-content": "var(--base-content)",
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
    defaultTheme: "mytheme",
  },

};
