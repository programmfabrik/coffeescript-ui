const coffee = require('coffeescript');
const babelJest = require('babel-jest');

module.exports = {
    process: (src, path) => {
        if (coffee.helpers.isCoffee(path)) {
            return coffee.compile(src, {bare: true});
        }
        if (!/node_modules/.test(path)) {
            return babelJest.process(src, path);
        }
        return src;
    }
};