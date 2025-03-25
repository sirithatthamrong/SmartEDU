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
  // daisyui: {
  //   themes: [
  //     {
  //       pastel: {
  //         "primary": "hsl(var(--p) / <alpha-value>)",
  //         "secondary": "hsl(var(--s) / <alpha-value>)",
  //         "accent": "hsl(var(--a) / <alpha-value>)",
  //         "base-100": "hsl(var(--bc) / <alpha-value>)",
  //       },
  //     },
  //   ],
  //   defaultTheme: "pastel",
  // }
  daisyui: {
    themes: ["light", "dark", "pastel"],
    darkTheme: "dark", // if you use dark mode
  },
  daisyui: {
    themes: [
      {
        mytheme: {
          "primary": "var(--primary)",
          "secondary": "var(--secondary)",
          "accent": "var(--accent)",
          "base-100": "var(--base-100)",
          "base-200": "var(--base-200)",
          "base-300": "var(--base-300)",
          "base-content": "var(--background)",
          "info": "#3ABFF8",
          "success": "#36D399",
          "warning": "#FBBD23",
          "error": "#F87272",
        },
      },
    ],
    defaultTheme: "mytheme",
  },

};
