const gulp = require('gulp');
const chokidar = require('chokidar');
const rename = require('gulp-rename');
const svgstore = require('gulp-svgstore');
const svgmin = require('gulp-svgmin');
const cheerio = require('cheerio');
const through2 = require('through2');
const Vinyl = require('vinyl'); // required if you use newer Vinyl versions

// result filename "icons.svg" is the name of base directory of the first file.
const iconsource = ['src/scss/icons/*.svg', '!src/scss/icons/icons.svg']

gulp.task('svgstore', function () {
  return gulp
    .src(iconsource) // Your icons source path
    .pipe(rename({ prefix: 'svg-' }))
    .pipe(svgmin()) // Minifying SVGs
    .pipe(through2.obj(function (file, encoding, cb) {
      // Load the SVG contents using Cheerio
      const $ = cheerio.load(file.contents.toString(), { xmlMode: true });

      const $svg = $('svg');

      // If viewBox is missing but width & height are present, add a viewBox
      const width = parseFloat($svg.attr('width'));
      const height = parseFloat($svg.attr('height'));
    
      if (!$svg.attr('viewBox') && width && height) {
        $svg.attr('viewBox', `0 0 ${width} ${height}`);
      }      

      // Perform your manipulation with Cheerio
      $('[fill="#023979"]').removeAttr('fill').parents('[fill="none"]').removeAttr('fill');
      $('[fill="#50E3C2"]').attr('fill', 'currentColor').parents('[fill="none"]').removeAttr('fill');

      // Update the file contents after manipulation
      file.contents = Buffer.from($.xml()); // Ensure it’s still in XML format

      cb(null, file);
    }))
    .pipe(svgstore()) // Combine the SVGs into a sprite
    .pipe(through2.obj(function (file, encoding, cb) {
      const $ = cheerio.load(file.contents.toString(), { xmlMode: true });

      // Generate CSS for the SVG symbols
      const data = $('svg > symbol').map(function () {
        const viewBox = $(this).attr('viewBox');

        if (viewBox) {
          const dimensions = viewBox.split(" ");
          return [
            '.' + $(this).attr('id') + ' {' +
            ' width: ' + dimensions[2] + 'px;' +
            ' height: ' + dimensions[3] + 'px; ' +
            '}'
          ];
        }
      }).get();

      // Create a new Vinyl file to store the generated CSS
      const cssFile = new Vinyl({
        path: '_svg-dimensions.scss',
        contents: Buffer.from(data.join("\n"))
      });

      // Push the CSS and the original SVG sprite file
      this.push(cssFile);
      this.push(file);
      cb();
    }))
    .pipe(gulp.dest('src/scss/icons')); // Output the generated files
});


/**
 * Copy thirdparty CSS modules from node_modules into a thirdparty folder
 * this way we can @import and build them into the themes without the need to run `npm i` in CUI
 * this was a problem because in CI we don't want to install CUI dev dependencies when building the webfrontend
 */
gulp.task('thirdparty', function() {
  return gulp.src([
    'node_modules/leaflet/dist/**/*.+(css|png)',
    'node_modules/leaflet-defaulticon-compatibility/dist/**/*.+(css|png)',
  ], { base: 'node_modules/' })
  .pipe(gulp.dest('src/scss/thirdparty'));
});


gulp.task('default', function () {
  const watcher = chokidar.watch(iconsource, {
    persistent: true,
  });

  watcher.on('change', (path) => {
    console.log(`File ${path} changed. Running svgstore...`);
    gulp.series('svgstore')(() => {});
  });

  watcher.on('add', (path) => {
    console.log(`File ${path} added. Running svgstore...`);
    gulp.series('svgstore')(() => {});
  });

  watcher.on('unlink', (path) => {
    console.log(`File ${path} removed. Running svgstore...`);
    gulp.series('svgstore')(() => {});
  });
});