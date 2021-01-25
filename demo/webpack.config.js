const path = require('path');

const webpack = require('webpack');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');

const BUILD_DIR = path.resolve(__dirname + path.sep, 'public');
const APP_DIR = path.resolve(__dirname + path.sep, 'src');

module.exports = function(env) {
    const isProduction = !!(env && env.production);

    return {
        mode: isProduction ? 'production' : 'development',
        context: APP_DIR,
        entry: {
            main_js: './index.coffee',
            cui_demo: APP_DIR + '/scss/demo.scss',
            cui_fylr: '../../src/scss/themes/fylr/main.scss',
            cui_debug: '../../src/scss/themes/debug/main.scss',
            cui_ng: '../../src/scss/themes/ng/main.scss',
        },
        output: {
            path: BUILD_DIR,
            filename: (chunkData) => {
                // we cannot prevent wp from generating a js output for each css only entry,
                // each emitted js file must therefore have a unique filename to prevent error: "Multiple chunks emit assets to the same filename"
                if (chunkData.chunk.id === 'main_js') {
                    return 'cui-demo.js';
                } else {
                    return 'not-needed/[name].js'
                }
            },
        },
        optimization: {
            namedChunks: true, // needed so we can use [id].css to name the extracted css files,
            minimize: isProduction,
            minimizer: [
                new TerserPlugin({
                    cache: true,
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
        devServer: {
            publicPath: '/public/',
            writeToDisk: true, // needs to be turned on because the theme files are loaded from disk and not from an inline <style>
        },
        module: {
            rules: [
            {
                test: /\.coffee/,
                loader: 'coffee-loader'
            },
            {
                test: /\.scss$/,
                use: [
                    { loader: MiniCssExtractPlugin.loader },
                    { loader: 'css-loader', options: { sourceMap: true } },
                    { loader: 'postcss-loader', options: {
                        config: { path: __dirname, ctx: { optimize: isProduction } },
                        sourceMap: true,
                    }},
                    { loader: 'sass-loader', options: { sourceMap: true } },
                ],
            },
            {
                test: /(icons\.svg|\.txt)/,
                loader: 'raw-loader'
            },
            {
                test: /\.(jpe?g|png|ttf|eot|svg|woff(2)?)(\?[a-z0-9=&.]+)?$/,
                exclude: /icons\.svg/,
                use: 'base64-inline-loader?limit=150000&name=[name].[ext]'
            },
            {
                test: /\.(html)$/,
                loader: 'html-loader'
			},
            ]
        },
        plugins: [
			new CleanWebpackPlugin({
				cleanAfterEveryBuildPatterns: [
					BUILD_DIR + '/not-needed', // Removes not-needed js files that are emitted from the scss only entries
				]
			}),
            new MiniCssExtractPlugin({
                moduleFilename: ({ id }) => {
                    if ( id === 'cui_demo') {
                        return 'cui-demo.css';
                    } else {
                        return '/css/[id].css';
                    }
                },
            }),
            new webpack.ProvidePlugin({
                'Demo': APP_DIR + '/Demo.coffee',
                'CUI': 'coffeescript-ui/public/cui.js'
            }),
        ],
    };
};
