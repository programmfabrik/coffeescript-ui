const path = require('path');

const webpack = require('webpack');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const FixStyleOnlyEntriesPlugin = require('webpack-fix-style-only-entries');
const TerserPlugin = require('terser-webpack-plugin');
const StylelintPlugin = require('stylelint-webpack-plugin');
// const HardSourceWebpackPlugin = require('hard-source-webpack-plugin');
const BUILD_DIR = path.resolve(__dirname + path.sep, 'public');
const APP_DIR = path.resolve(__dirname + path.sep, 'src');

module.exports = function (env, argv) {
    const isProduction = !!(env && env.production);
    
    let plugins = [
        // new HardSourceWebpackPlugin(), We comment out the plugin due to https://github.com/mzgoddard/hard-source-webpack-plugin/issues/480
        
        new FixStyleOnlyEntriesPlugin(), // Removes extraneous js files that are emitted from the scss only entries
        new MiniCssExtractPlugin({ filename: '[id].css' }),
        new webpack.ProvidePlugin({
            'CUI': APP_DIR + '/base/CUI.coffee'
        }),
        new webpack.ContextReplacementPlugin(/moment[\/\\]locale$/, /de|en|es|it/),
        new CleanWebpackPlugin([
            BUILD_DIR + '/' + 'cui.js',
            BUILD_DIR + '/' + 'cui.js.map',
            BUILD_DIR + '/' + 'cui.min.js',
            BUILD_DIR + '/' + 'cui.min.js.map',
            BUILD_DIR + '/' + 'cui.css', 
            BUILD_DIR + '/' + 'cui.css.map',
            BUILD_DIR + '/' + 'cui_fylr.css',
            BUILD_DIR + '/' + 'cui_fylr.css.map',
            BUILD_DIR + '/' + 'cui_debug.css',
            BUILD_DIR + '/' + 'cui_debug.css.map',
        ]),
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
            filename: (chunkData) => {   
                // we cannot prevent wp from generating a js output for each css only entry,
                // each emitted js file must therefore have a unique filename to prevent error: "Multiple chunks emit assets to the same filename"
                if (chunkData.chunk.id === 'main_js') {
                    return 'cui' + (isProduction ? '.min' : '') + '.js';                    
                } else if (chunkData.chunk.id === 'cui') {
                    // since cui.js already exists from `main_js` output, we need to create a more unique name here
                    return '[name]_[id].js';
                } else {
                    return '[name].js'
                }
            },
            path: BUILD_DIR,
            libraryTarget: 'umd',
            library: 'CUI'
        },
        optimization: {
            namedChunks: true, // needed so we can use [id].css to name the extracted css files,
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
                        { loader: "postcss-loader", options: { 
                            config: { path: __dirname, ctx: { optimize: isProduction } },
                            sourceMap: true,
                        }},                       
                        { loader: "sass-loader", options: { sourceMap: true } }, 
                    ]                    
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
        plugins: plugins
    }
};