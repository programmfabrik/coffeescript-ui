const path = require('path');

const CleanWebpackPlugin = require('clean-webpack-plugin');
const webpack = require('webpack');
const ExtractTextWebpackPlugin = require("extract-text-webpack-plugin");

// const HardSourceWebpackPlugin = require("hard-source-webpack-plugin");

const BUILD_DIR = path.resolve(__dirname + path.sep, 'public');
const APP_DIR = path.resolve(__dirname + path.sep, 'src');

const extractSass = new ExtractTextWebpackPlugin("cui.css");
const fylrExtractSass = new ExtractTextWebpackPlugin("cui_fylr.css");
const debugExtractSass = new ExtractTextWebpackPlugin("cui_debug.css");

const config = {
    context: APP_DIR,
    entry: './index.coffee',
    output: {
        path: BUILD_DIR,
        libraryTarget: "umd",
        library: "CUI"
    },
    module: {
        rules: [
            {

                test: /\.coffee/,
                loader: 'coffee-loader'
            },
            {
                test: /themes\/ng\/.*\.scss$/,
                use: extractSass.extract({
                    use: [{
                        loader: "css-loader"
                    }, {
                        loader: "sass-loader"
                    }]
                })
            },
            {
                test: /themes\/fylr\/.*\.scss$/,
                use: fylrExtractSass.extract({
                    use: [{
                        loader: "css-loader"
                    }, {
                        loader: "sass-loader"
                    }]
                }),
            },
            {
                test: /themes\/debug\/.*\.scss$/,
                use: debugExtractSass.extract({
                    use: [{
                        loader: "css-loader"
                    }, {
                        loader: "sass-loader"
                    }]
                })
            },
            {
                test: /icons\.svg/,
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
        // new HardSourceWebpackPlugin(), We comment out the plugin due to https://github.com/mzgoddard/hard-source-webpack-plugin/issues/480
        extractSass,
        fylrExtractSass,
        debugExtractSass,
        new webpack.ProvidePlugin({
            'CUI': APP_DIR + '/base/CUI.coffee'
        }),
        new webpack.ContextReplacementPlugin(/moment[\/\\]locale$/, /de|en|es|it/)
    ]
};

module.exports = function (env) {
    config.output.filename = "cui";

    if (env) {
        if (env.minify) {
            config.output.filename += ".min";
            config.plugins.push(new webpack.optimize.UglifyJsPlugin({
                compress: {warnings: false, keep_fnames: true},
                mangle: {keep_classnames: true, keep_fnames: true}
            }));
        }
    }

    config.output.filename += ".js";
    config.plugins.push(new CleanWebpackPlugin(BUILD_DIR + "/" + config.output.filename));

    return config
};