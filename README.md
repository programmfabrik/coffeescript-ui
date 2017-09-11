# Coffeescript User Interface System (CUI)

## Install dependency

    npm install --save-dev git+https://github.com/programmfabrik/coffeescript-ui.git

## Different versions

- **cui.js**: No minified, includes CSS
- **cui.no-css.js**: No minified, no CSS
- **cui.min.js**: Minified, includes CSS (default version)     
- **cui.no-css.min.js**: Minified, no CSS  

## Usage

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
  
## Build

    git clone https://github.com/programmfabrik/coffeescript-ui.git coffeescript-ui
    git submodule init
    git submodule update
      
    npm install
    npm run build

You will find the bundled file inside **public** folder.

### Build options

- No CSS: --env.noCss
- Minify: --env.minify

_Example:_

**npm run build -- --env.minify --env.noCss**

_It will generate a different filename depending in the options that were used (see **Different versions**)_

## Documentation

*Work in progress*
