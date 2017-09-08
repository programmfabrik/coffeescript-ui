const path = require('path');

const CleanWebpackPlugin = require('clean-webpack-plugin');
const webpack = require('webpack');

const BUILD_DIR = path.resolve(__dirname + path.sep, 'public');
const APP_DIR = path.resolve(__dirname + path.sep, 'src');

const config = {
    context: APP_DIR,
    entry: ['./index.coffee', './scss/themes/ng/main.scss'],
    output: {
        path: BUILD_DIR,
        filename: 'cui.js',
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
                test: /\.scss$/,
                loaders: ['style-loader', 'css-loader', 'sass-loader']
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

    if (env.noCss) {
        config.entry.pop();
    }

    if (env.minify) {
        config.plugins.push(new webpack.optimize.UglifyJsPlugin({
            compress: {warnings: false, keep_fnames: true},
            mangle: {keep_classnames: true, keep_fnames: true}
        }));
    }

    return config
};