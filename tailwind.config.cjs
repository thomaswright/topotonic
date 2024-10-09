/** @type {import('tailwindcss').Config} */

const tailwindColors = require("tailwindcss/colors");

const primary = tailwindColors["blue"];
const secondary = tailwindColors["cyan"];
const accent = tailwindColors["red"];

module.exports = {
  content: ["./src/**/*.{js,jsx,tsx,ts}"],
  theme: {
    extend: {
      gridTemplateColumns: {
        main: "2fr 3fr",
      },
      colors: {
        primary,
        secondary,
        accent,
        plain: tailwindColors["slate"],
      },
      screens: {
        xs: "380px",
      },
      keyframes: {
        overlayShow: {
          from: { opacity: "0" },
          to: { opacity: "1" },
        },
        contentShow: {
          from: {
            opacity: "0",
            transform: "translate(-50%, -48%) scale(0.96)",
          },
          to: { opacity: "1", transform: "translate(-50%, -50%) scale(1)" },
        },
      },
      animation: {
        overlayShow: "overlayShow 150ms cubic-bezier(0.16, 1, 0.3, 1)",
        contentShow: "contentShow 150ms cubic-bezier(0.16, 1, 0.3, 1)",
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
