const path = require('path');
const webpack = require('webpack');

const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const StylelintPlugin = require('stylelint-webpack-plugin');
const BUILD_DIR = path.resolve(__dirname, 'public');
const APP_DIR = path.resolve(__dirname, 'src');

module.exports = function (env, argv) {
	const isProduction = !!(env && env.production);
	const isBuildAll = !!(env && env.all);
    
    let plugins = [
        // new HardSourceWebpackPlugin(), We comment out the plugin due to https://github.com/mzgoddard/hard-source-webpack-plugin/issues/480

		// use CleanWebpackPlugin to explicitly clear the not-needed folder ONLY
		new CleanWebpackPlugin({
			cleanStaleWebpackAssets: false,
			cleanOnceBeforeBuildPatterns: [], // disables the default behavior that removes all files from the build directory before running
			cleanAfterEveryBuildPatterns: [
				BUILD_DIR + '/not-needed', // removes not-needed js files that are emitted from the scss only entries
			]
		}),
        new MiniCssExtractPlugin({ filename: '[name]' + (isProduction && isBuildAll ? '.min' : '') + '.css' }),
        new webpack.ProvidePlugin({
            'CUI': APP_DIR + '/base/CUI.coffee'
        }),
		new webpack.ContextReplacementPlugin(/moment[\/\\]locale$/, /de|en|es|it/),
        new StylelintPlugin({
            fix: true,
            context: APP_DIR + '/scss/themes/fylr',
            syntax: 'scss',
            failOnError: !argv.watch,
        }),
	];

    return {
        mode: isProduction ? 'production' : 'development',
        context: APP_DIR,
        entry: {
            main_js: './index.coffee',
            cui_fylr: APP_DIR + '/scss/themes/fylr/main.scss',
            cui_debug: APP_DIR + '/scss/themes/debug/main.scss',
            cui: APP_DIR + '/scss/themes/ng/main.scss',
        },
        output: {
            filename: (pathData) => {
                const chunkId = pathData.chunk.name.toString();
                if (chunkId.includes('main_js')) {
                    return isProduction ? 'cui.min.js' : 'cui.js';
                } else if (chunkId.includes('cui')) {
                    return 'not-needed/[name]_[id].js';
                } else {
                    return 'not-needed/[name].js';
                }
            },
            path: BUILD_DIR,
            libraryTarget: 'umd',
            library: 'CUI'
        },
        optimization: {
            minimize: isProduction,
            minimizer: [
                new TerserPlugin({
                    parallel: true,
                    // sourceMap: true, // Must be set to true if using source-maps in production
                    extractComments: false,
                    terserOptions: {
                        // https://github.com/webpack-contrib/terser-webpack-plugin#terseroptions
                        warnings: false,
                        keep_classnames: true,
                        keep_fnames: true,
                    }
                }),
            ],
        },
        devtool: (!isProduction ? 'source-map' : undefined),     
        module: {
            rules: [
                {
                    test: /\.coffee/,
                    loader: 'coffee-loader'
                },
                {
                    test: /\.scss$/,
                    use: [
                        MiniCssExtractPlugin.loader,
                        { loader: "css-loader", options: { sourceMap: true } },
                        {
                            loader: 'postcss-loader',
                            options: {
                              postcssOptions: {
                                config: process.cwd(),
                                ctx: {
                                  optimize: isProduction,
                                },
                              },
                              sourceMap: true,
                            }
                        },
                        {
                            // resolve fully relative paths in SCSS, especially when importing CSS from node_modules (leaflet)
                            loader: 'resolve-url-loader',
                            options: {
                                sourceMap: true,
                                // debug: true
                            }
                        },                        
                        {
                            loader: 'sass-loader',
                            options: {
                              implementation: require('sass'),
                              sourceMap: true
                            },
                        },
                    ]
                },
                {
                    test: /icons\.svg/,
                    loader: 'raw-loader'
                },
                {
                    test: /\.(jpe?g|png|ttf|eot|svg|woff(2)?)(\?[a-z0-9=&.]+)?$/,
                    exclude: /icons\.svg/,
                    type: 'asset/inline',
                    parser: {
                        dataUrlCondition: {
                            maxSize: 150 * 1024 // 150 KB
                        },
                    }        
                },
                {
                    test: /\.(html)$/,
                    loader: 'html-loader'
                }
            ]
        },
        plugins: plugins
    }
};
