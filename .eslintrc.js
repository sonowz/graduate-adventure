module.exports = {
  root: true,
  parser: 'babel-eslint',
  env: {
    es6: true,
    browser: true,
    node: true
  },
  extends: 'eslint:recommended',
  // required to lint *.vue files
  plugins: [
    'html'
  ],
  // TODO: add more rules
  rules: {
    "indent": ["error", 2],
    "quotes": [2, "single"],
    "camelcase": "error",
    "eqeqeq": ["error", "always"],
    "no-param-reassign": ["error", { "props": false }],
    "no-console": 1,
  },
  globals: {}
}
