const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
        body: ['Open Sans'],
        heading: ['Afacad Flux']
      },
    },
    colors: {
      "primary": "#4f8b8b",
      "primary-dark": "#10375C",
      "complementary": "#F3C623",
      "complementary-dark": "#EB8317",
      "contrast": "#F4F6FF",
      "white": "white",
      "success": "#6FE051",
      "danger": "#CC0909",
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
