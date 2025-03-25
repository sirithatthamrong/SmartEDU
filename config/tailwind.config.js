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
      colors: {
        primary: 'var(--primary)',
        secondary: 'var(--secondary)',
        tertiary: 'var(--tertiary)',
        accent: 'var(--accent)',
      },
    },
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("daisyui"),
  ],
  // daisyui: {
  //   themes: ["light", "dark", "pastel"], // optional preset themes
  //   darkTheme: "dark", // if you use dark mode
  // },
  daisyui: {
    themes: [
      {
        mytheme: {
          "primary": "var(--primary)",
          "secondary": "var(--secondary)",
          "tertiary": "var(--tertiary)",
          "accent": "var(--accent)",
          "base-100": "#FFFFFF",
          "info": "#3ABFF8",
          "success": "#36D399",
          "warning": "#FBBD23",
          "error": "#F87272",
        },
      },
    ],
  },
};
