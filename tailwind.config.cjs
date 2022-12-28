/** @type {import('tailwindcss').Config} */

const tailwindColors = require("tailwindcss/colors");

const primary = tailwindColors["blue"];
const secondary = tailwindColors["cyan"];
const accent = tailwindColors["red"];

module.exports = {
  content: ["./src/**/*.{js,jsx,tsx,ts}"],
  theme: {
    extend: {
      colors: {
        primary,
        secondary,
        accent,
        plain: tailwindColors["slate"],
      },
      screens: {
        xs: "380px",
      },
    },
  },
  plugins: [
    // require("daisyui"),
    // require("@tailwindcss/forms"),
    // require("@tailwindcss/typography"),
    // require("@tailwindcss/line-clamp"),
  ],
  // daisyui: {
  //   prefix: "daisy-",
  //   themes: [
  //     {
  //       light: {
  //         ...daisyThemes["[data-theme=winter]"],
  //         "--btn-text-case": "normal-case",
  //         primary: primary[500],
  //         secondary: secondary[500],
  //         accent: accent[500],
  //         neutral: neutral[200],
  //       },
  //     },
  //   ],
  // },
};
