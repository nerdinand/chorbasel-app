const defaultTheme = require("tailwindcss/defaultTheme");

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
      primary: "#4F8B8B",
      "primary-dark": "#2F6363",
      "primary-darker": "#1E4545",
      complementary: "#FDC04E",
      "complementary-dark": "#A98034",
      contrast: "#E6F0F0",
      white: "white",
      success: "#4F8B8B",
      danger: "#C43F66",
      ink: "#050505",
      body: "#323232",
      muted: "#555555",
      line: "#E2E2E3",
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
