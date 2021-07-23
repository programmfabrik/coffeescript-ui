const path = require('path');
const webpack = require('webpack');

const BUILD_DIR = path.resolve(__dirname, 'public');
const APP_DIR = path.resolve(__dirname, 'src');

const config = {
    context: APP_DIR,
    entry: './App.coffee',
    output: {
        path: BUILD_DIR,
        filename: 'cui-tutorial.js'
    },
    module: {
        rules: [
            {
                test: /\.coffee/,
                loader: 'coffee-loader'
            },
            {
                test: /\.css$/,
                loaders: ['style-loader', 'css-loader']
            },
            {
                test: /\.scss$/,
                loaders: ['style-loader', 'css-loader', 'sass-loader']
            },
            {
                test: /\.(html)$/,
                loader: 'html-loader'
            }
        ]
    },
    plugins: [
        new webpack.ProvidePlugin({
            'CUI': "coffeescript-ui/public/cui.js"
        })
    ]
};

module.exports = config;