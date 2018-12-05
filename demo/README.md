# Demo - Coffeescript-ui

## Live demo

https://programmfabrik.github.io/coffeescript-ui/demo/index.html

## Installation

The first step is to download all dependencies with *npm install*

Then you can run different targets, with *npm run **%TARGET%***

**%TARGET%** should be one of the following:

- **build**: Builds the demo with CSS
- **build:watch**: Builds the demo with CSS and watch for changes
- **build:no-css** Builds the demo without CSS

As output, there will be two files: *cui-demo.js* and *index.html*, located in **public** directory. Open **public/index.html** too see the demo.

## Run

- npm start
- Open http://localhost:8080/

## Using **coffeescript-ui** locally

If it's required to work with coffeescript-ui as local dependency, it's necessary to change the next line in *package.json*:

<pre>
    devDependencies: {
        ...
        "coffeescript-ui": <s>"git+https://github.com/programmfabrik/coffeescript-ui.git"</s>,
        "coffeescript-ui": "file:./<b>%COFFEESCRIPT_UI_PATH%</b>",
        ...
    } 
</pre>

**%COFFEESCRIPT_UI_PATH%** must be the path of coffeescript-ui. 

*For example:*

<pre>
    "coffeescript-ui": "file:./coffeescript-ui",
</pre>

**Important**: You must run *npm install* again to see the changes