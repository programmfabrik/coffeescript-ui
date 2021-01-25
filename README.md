[![NPM version](https://img.shields.io/npm/v/coffeescript-ui.svg)](https://www.npmjs.com/package/coffeescript-ui)

# Coffeescript User Interface System (CUI)

## Documentation

https://programmfabrik.gitbooks.io/coffeescript-ui/

https://programmfabrik.github.io/coffeescript-ui/doc/index.html

## Installation

```
npm install --save-dev git+https://github.com/programmfabrik/coffeescript-ui.git
```

**Icons:** It is necessary to include [font-awesome](https://fontawesome.com) to be able to use icons. CUI also provides some icons which can be used with **svg-** prefix.

### Versions

- **cui.min.js**: Minified (default version)
- **cui.js**: No minified (recommended for development)

### Usage

With *require*

```
require('coffeescript-ui') (uses default version)
require('coffeescript-ui/public/cui.js')
```

With *\<script\>* tag

```
<script src="node_modules/coffeescript-ui/public/cui.min.js" type="text/javascript" charset="utf-8"></script>
<script src="node_modules/coffeescript-ui/public/cui.js" type="text/javascript" charset="utf-8"></script>
```

#### Use cui.css (Optional, recommended)

With CUI.CSSLoader

```
CUI.ready ->
    new CUI.CSSLoader().load(url: 'node_modules/coffeescript-ui/public/cui.css')
```

With require

```
require('coffeescript-ui/public/cui.css')
```

With *\<link\>* tag

```
<link rel="stylesheet" type="text/css" href="node_modules/coffeescript-ui/public/cui.css">
```

### Usage with webpack

It's recommended to use **webpack.ProvidePlugin** to avoid "require" in each file.

```
plugins: [
    ...
    new webpack.ProvidePlugin({
        'CUI': "coffeescript-ui" // or "coffeescript-ui/public/cui.js" (for development)
    })
    ...
]
```

## Build

The first step is to download all dependencies with *npm install*

After that, it's necessary to run one of the following build commands

- **npm run build**: Builds the default version for development
- **npm run build:production**: Builds the default version for production (minified, no sourcemaps)
- **npm run build:watch**: Builds the default version and watch for changes
- **npm run build:all**: Builds both minified JS and CSS as well as non-minified/development versions with no sourcemaps. "cui.min.js" or "cui.js" are used in the final build (see makefile), "cui.js" is used in the DEMO.)

# Deprecated:
- **npm run build:min**: Builds the minified version, run **npm run build:production** instead

You will find the bundled file inside **public** folder.

It's not necessary to build the project before use it, because **public** directory has always the last version.

# Icons:
- **gulp svgstore**: Build the icons.svg from all icons included in /scss/icons

## Test

To run the tests:

**npm run test**

## Live Demo

https://programmfabrik.github.io/coffeescript-ui/demo/index.html

## Live Tutorial

https://programmfabrik.github.io/coffeescript-ui/tutorial/index.html
