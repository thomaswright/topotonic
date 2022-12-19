/** @type {import('tailwindcss').Config} */

const tailwindColors = require("tailwindcss/colors");

const primary = tailwindColors["blue"];
const secondary = tailwindColors["cyan"];
const accent = tailwindColors["amber"];
const neutral = tailwindColors["slate"];

module.exports = {
  content: ["./src/**/*.{js,jsx,tsx,ts}"],
  theme: {
    extend: {
      colors: {
        primary,
        secondary,
        accent,
        plain: tailwindColors["slate"],
        any: tailwindColors["sky"],
        every: tailwindColors["purple"],
        exclude: tailwindColors["red"],
        selectedItem: tailwindColors["blue"],
        ancItem: tailwindColors["sky"],
        selectedTag: tailwindColors["slate"],
        defaultMark: tailwindColors["slate"],
        highlight1: tailwindColors["amber"],
        highlight2: tailwindColors["emerald"],
        highlight3: tailwindColors["rose"],
        highlight4: tailwindColors["purple"],
        violation: tailwindColors["red"],
        nestLevel0: tailwindColors["blue"],
        nestLevel1: tailwindColors["sky"],
        nestLevel2: tailwindColors["teal"],
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
