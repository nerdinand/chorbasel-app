const defaultTheme = require("tailwindcss/defaultTheme");

// Colors are CSS variables (RGB channels) defined in application.tailwind.css,
// so dark mode only has to swap the variables.
const color = (name) => `rgb(var(--color-${name}) / <alpha-value>)`;

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
        body: ['"Helvetica Neue"', "Helvetica", "Arial", "sans-serif"],
        heading: ["Poppins", "sans-serif"],
      },
    },
    colors: {
      primary: color("primary"),
      "primary-dark": color("primary-dark"),
      "primary-darker": color("primary-darker"),
      "on-primary": color("on-primary"),
      complementary: color("complementary"),
      "complementary-dark": color("complementary-dark"),
      contrast: color("contrast"),
      white: "white",
      transparent: "transparent",
      success: color("primary"),
      danger: color("danger"),
      bg: color("bg"),
      ink: color("ink"),
      body: color("body"),
      muted: color("muted"),
      line: color("line"),
      notice: color("notice"),
      "notice-line": color("notice-line"),
    },
    // The new design has square corners everywhere.
    borderRadius: {
      none: "0",
      sm: "0",
      DEFAULT: "0",
      md: "0",
      lg: "0",
      xl: "0",
      "2xl": "0",
      "3xl": "0",
      full: "0",
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
  ],
};
