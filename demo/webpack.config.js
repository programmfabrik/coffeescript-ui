const path = require('path');
const webpack = require('webpack');

const CopyPlugin = require('copy-webpack-plugin');

const BUILD_DIR = path.resolve(__dirname + path.sep, 'public');
const APP_DIR = path.resolve(__dirname + path.sep, 'src');

const config = {
    context: APP_DIR,
    entry: './index.coffee',
    output: {
        path: BUILD_DIR,
        filename: 'cui-demo.js'
    },
    module: {
        loaders: [
        {
            test: /\.coffee/,
            loader: 'coffee-loader'
        },
        {
            test: /\.scss|\.css$/,
            loaders: ['style-loader', 'css-loader', 'sass-loader']
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
        new webpack.ProvidePlugin({
            'Demo': APP_DIR + '/Demo.coffee',
            'CUI': 'coffeescript-ui/public/cui.js'
        }),
        new CopyPlugin([
            { from: '../node_modules/coffeescript-ui/public/cui.css', to: BUILD_DIR + "/css/cui_ng.css" },
            { from: '../node_modules/coffeescript-ui/public/cui_fylr.css', to: BUILD_DIR + "/css" },
            { from: '../node_modules/coffeescript-ui/public/cui_debug.css', to: BUILD_DIR + "/css" }
        ])
    ]
};

module.exports = function(env){

    if(env && env.noCss) {
        config.entry = './index.no-css.coffee';
    }

    return config;
};
