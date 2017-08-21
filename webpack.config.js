const path = require('path');

const ExtractTextPlugin = require("extract-text-webpack-plugin");
const CleanWebpackPlugin = require('clean-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const ConcatPlugin = require('webpack-concat-plugin');
const webpack = require('webpack');

const BUILD_DIR = path.resolve(__dirname + path.sep, 'public');
const APP_DIR = path.resolve(__dirname + path.sep, 'src');

const htmlFiles = require('./html-files');

const config = {
    context: APP_DIR,
    entry: './index.coffee',
    output: {
        path: BUILD_DIR,
        filename: 'cui.js',
        publicPath: '/cui/',
        libraryTarget: "var",
        library: "CUI"
    },
    module: {
        loaders: [
            {
                test: /\.coffee/,
                loader: 'coffee-loader'
            },
            {
                test: /\.less$/,
                loader: ['style-loader', 'css-loader!less-loader']
            },
            {
                test: /\.scss$/,
                loader: ExtractTextPlugin.extract({
                    fallback: 'style-loader',
                    use: [{loader: 'css-loader'}, {loader: 'sass-loader'}]
                })
            },
            {
                test: /\.(jpg|png|svg)$/,
                loader: 'url-loader'
            },
            {
                test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                loader: "url-loader?limit=10000&mimetype=application/font-woff"
            },
            {
                test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                loader: "file-loader"
            }
        ]
    },
    plugins: [
        new CleanWebpackPlugin(BUILD_DIR),
        new ExtractTextPlugin("css/cui_ng.css"),
        new CopyWebpackPlugin(
            [
                {from: 'scss/icons/icons.svg', to: 'css/icons.svg'}
            ]
        ),
        new ConcatPlugin({
            fileName: 'cui.html',
            filesToConcat: htmlFiles
        }),
        new webpack.ProvidePlugin({
            'CUI': APP_DIR + '/base/CUI.coffee'
        })
    ]
};

module.exports = function (env) {
    if (!env) {
        return config;
    }

    if (env.minify) {
        config.plugins.push(new webpack.optimize.UglifyJsPlugin({
            compress: {warnings: false, keep_fnames: true},
            mangle: {keep_classnames: true, keep_fnames: true}
        }));
    }

    return config
};