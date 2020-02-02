const path = require('path');
const webpack = require('webpack');

const ExtractTextWebpackPlugin = require("extract-text-webpack-plugin");

const BUILD_DIR = path.resolve(__dirname + path.sep, 'public');
const APP_DIR = path.resolve(__dirname + path.sep, 'src');

const extractSass = new ExtractTextWebpackPlugin("cui-demo.css");
const ngExtractSass = new ExtractTextWebpackPlugin("css/cui_ng.css");
const fylrExtractSass = new ExtractTextWebpackPlugin("css/cui_fylr.css");
const debugExtractSass = new ExtractTextWebpackPlugin("css/cui_debug.css");

module.exports = function(env) {
    const isProduction = !!(env && env.production);

    return {
        context: APP_DIR,
        entry: './index.coffee',
        output: {
            path: BUILD_DIR,
            filename: 'cui-demo.js'
        },
        // devtool: env.development ? 'source-map' : '',
        devtool: (!isProduction ? 'source-map' : undefined),
        devServer: {
            publicPath: '/public/',
            // hot: true, // ExtractTextWebpackPlugin does not support HMR
        },
        module: {
            rules: [
            {
                test: /\.coffee/,
                loader: 'coffee-loader'
            },
            {
                test: /demo\.scss$/,
                use: extractSass.extract({
                    use: [
                        { loader: "css-loader", options: { sourceMap: true } },
                        { loader: "postcss-loader", options: { 
                            config: { path: __dirname, ctx: { optimize: isProduction } },
                            sourceMap: true,
                        }},
                        { loader: "sass-loader", options: { sourceMap: true } }, 
                    ]
                })
            },
            {
                test: /themes\/ng\/.*\.scss$/,
                use: ngExtractSass.extract({
                    use: [
                        { loader: "css-loader", options: { sourceMap: true } },
                        { loader: "postcss-loader", options: { 
                            config: { path: __dirname, ctx: { optimize: isProduction } },
                            sourceMap: true,
                        }},
                        { loader: "sass-loader", options: { sourceMap: true } }, 
                    ]
                })
            },
            {
                test: /themes\/fylr\/.*\.scss$/,
                use: fylrExtractSass.extract({
                    use: [
                        { loader: "css-loader", options: { sourceMap: true } },
                        { loader: "postcss-loader", options: { 
                            config: { path: __dirname, ctx: { optimize: isProduction } },
                            sourceMap: true,
                        }},
                        { loader: "sass-loader", options: { sourceMap: true } }, 
                    ]
                }),
            },
            {
                test: /themes\/debug\/.*\.scss$/,
                use: debugExtractSass.extract({
                    use: [
                        { loader: "css-loader", options: { sourceMap: true } },
                        { loader: "postcss-loader", options: { 
                            config: { path: __dirname, ctx: { optimize: isProduction } },
                            sourceMap: true,
                        }},
                        { loader: "sass-loader", options: { sourceMap: true } }, 
                    ]
                })
            },
            {
                test: /(icons\.svg|\.txt|\.json)/,
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
            }
            ]
        },
        plugins: [
            extractSass,
            ngExtractSass,
            fylrExtractSass,
            debugExtractSass,
            new webpack.ProvidePlugin({
                'Demo': APP_DIR + '/Demo.coffee',
                'CUI': 'coffeescript-ui/public/cui.js'
            })
        ]
    };
};
