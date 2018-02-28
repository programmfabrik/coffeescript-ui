# Coffeescript User Interface System (CUI)

## Installation and usage

    npm install --save-dev git+https://github.com/programmfabrik/coffeescript-ui.git

### Different versions

- **cui.min.js**: Minified (default version)     
- **cui.js**: No minified

### Usage with *require*

    require('coffeescript-ui') (uses default version)
    require('coffeescript-ui/public/cui.js')
        
### Usage with *\<script\>* tag
 
    <script src="node_modules/coffeescript-ui/public/cui.min.js" type="text/javascript" charset="utf-8"></script>
    <script src="node_modules/coffeescript-ui/public/cui.js" type="text/javascript" charset="utf-8"></script>
  
### Use cui.css

With CUI.CSSLoader

    CUI.ready ->
        new CUI.CSSLoader().load({url: 'node_modules/coffeescript-ui/public/cui.css'})

With require
        
    require('coffeescript-ui/public/cui.css')

### Usage with webpack

It's recommended to use **webpack.ProvidePlugin** to avoid "require" in each file.

    plugins: [
        ...
        new webpack.ProvidePlugin({
            'CUI': "coffeescript-ui"
        })
        ...
    ] 
  
## Build

The first step is to download all dependencies with *npm install*

After that, it's necessary to run one of the following build commands 

- **npm run build**: Builds the default version
- **npm run build:minify**: Builds the minified version
- **npm run build:all**: Builds one of each version
- **npm run build:watch**: Builds the default version and watch for changes

You will find the bundled file inside **public** folder.

## Test

To run the tests:

**npm run test**

## Documentation

https://programmfabrik.gitbooks.io/coffeescript-ui/

## Live DEMO

https://programmfabrik.github.io/coffeescript-ui/demo/index.html

## Live Tutorial

https://programmfabrik.github.io/coffeescript-ui/tutorial/index.html
