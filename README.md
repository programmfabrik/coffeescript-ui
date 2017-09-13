# Coffeescript User Interface System (CUI)

## Installation and usage

    npm install --save-dev git+https://github.com/programmfabrik/coffeescript-ui.git

### Different versions

- **cui.js**: No minified, includes CSS
- **cui.no-css.js**: No minified, no CSS
- **cui.min.js**: Minified, includes CSS (default version)     
- **cui.no-css.min.js**: Minified, no CSS  

### Usage with *require*

    cui = require('coffeescript-ui')

It will load the default version. It includes the CSS and It's minified.

#### Different versions with *require*

    require('coffeescript-ui/public/cui.js')
    require('coffeescript-ui/public/cui.no-css.js')
    require('coffeescript-ui/public/cui.min.js')
    require('coffeescript-ui/public/cui.no-css.min.js')
        
### Usage with *\<script\>* tag
 
    <script src="node_modules/public/cui.js" type="text/javascript" charset="utf-8"></script>
    <script src="node_modules/public/cui.no-css.js" type="text/javascript" charset="utf-8"></script>
    <script src="node_modules/public/cui.min.js" type="text/javascript" charset="utf-8"></script>
    <script src="node_modules/public/cui.no-css.min.js" type="text/javascript" charset="utf-8"></script>
  
### Usage with webpack

It's recommended to use **webpack.ProvidePlugin** to avoid "require" in each file. Also it's easier if you want to change the version

    plugins: [
        ...
        new webpack.ProvidePlugin({
            'CUI': "coffeescript-ui/public/cui.js"
        })
        ...
    ] 
  
## Build

The first step is to download all dependencies with *npm install*

After that, it's necessary to run one of the following build commands 

- **npm run build**: Builds the default version
- **npm run build:watch**: Builds the default version and watch for changes
- **npm run build:all**: Builds one of each version (it takes 2-3 minutes)

You will find the bundled file inside **public** folder.

### Build options

It's optional to add the following parameters to generate different versions:

- No CSS: --env.noCss
- Minify: --env.minify

_Example:_

**npm run build -- --env.minify --env.noCss**

_It will generate a different filename depending in the options that were used (see **Different versions**)_

## Documentation

*Work in progress*
