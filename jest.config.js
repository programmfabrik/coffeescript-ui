module.exports = {
    // collectCoverage: true,
    // collectCoverageFrom: ['src/**/*.coffee'],
    "setupFiles": [
        "./test/setup.js"
    ],
    "transform": {
        "^.+\\.coffee$": "./test/preprocessor.js",
        "^.+\\.html$": "./test/html-loader.js"
    }
}