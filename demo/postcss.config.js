const cssnanoConfig = {
  preset: ['default', { discardComments: true }]
};

module.exports = function({ file, options }) {
  return {
    plugins: {
      autoprefixer: { grid: false },
      cssnano: options.optimize ? cssnanoConfig : false,
    },
  };
};
