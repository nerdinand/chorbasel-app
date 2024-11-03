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
    // colors: {
    //   "primary": "#4f8b8b",
    //   "primary-dark": "#376161",
    //   "complementary": "#F3C623",
    //   "complementary-dark": "#613757",
    //   "contrast": "#8b7f4f",
    //   "gray": "#F4F6FF",
    //   "white": "white",
    // },
    colors: {
      "primary": "#10375C",
      "primary-dark": "#376161",
      "complementary": "#EB8317",
      "complementary-dark": "#613757",
      "complementary-light": "#F3C623",
      "contrast": "#F3C623",
      "gray": "#F4F6FF",
      "white": "white",
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
