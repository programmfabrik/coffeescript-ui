const cssnanoConfig = {
  preset: ['default', { discardComments: true }]
};

module.exports = function({ file, options }) {
  return {
    plugins: {
      autoprefixer: { grid: true },
      cssnano: options.optimize ? cssnanoConfig : false,
    },
  };
};
