const path = require('path');

const CleanWebpackPlugin = require('clean-webpack-plugin');
const webpack = require('webpack');

const BUILD_DIR = path.resolve(__dirname + path.sep, 'public');
const APP_DIR = path.resolve(__dirname + path.sep, 'src');

const config = {
    context: APP_DIR,
    entry: './index.coffee',
    output: {
        path: BUILD_DIR,
        filename: 'cui.js',
        publicPath: '/cui/',
        libraryTarget: "umd",
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
                loaders: ['style-loader', 'css-loader', 'sass-loader']
            },
            {
                test: /icons\.svg/,
                loader: 'raw-loader'
            },
            {
                test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                loader: "url-loader?limit=10000&mimetype=application/font-woff"
            },
            {
                test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                exclude: /icons\.svg/,
                loader: "file-loader"
            },
            {
                test: /\.(html)$/,
                loader: 'html-loader'
            }
        ]
    },
    plugins: [
        new CleanWebpackPlugin(BUILD_DIR),
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