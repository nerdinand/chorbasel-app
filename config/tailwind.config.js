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
      "primary-dark": "#376161",
      "complementary": "#8b4f7c",
      "complementary-dark": "#613757",
      "contrast": "#8b7f4f",
      "white": "white",
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
