module.exports = {
  env: {
    es6: true,
    node: true,
  },
  extends: "eslint:recommended",
  rules: {
    "no-console": "off", // Permite el uso de console.log
  },
  parserOptions: {
    ecmaVersion: 2018,
  },
};