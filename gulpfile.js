var gulp = require('gulp');
var gutil = require('gulp-util');
var rename = require('gulp-rename');
var svgstore = require('gulp-svgstore');
var svgmin = require('gulp-svgmin');
var cheerio = require('gulp-cheerio');
var through2 = require('through2');

// result filename "icons.svg" is the name of base directory of the first file.
var iconsource = ['src/scss/icons/*.svg', '!src/scss/icons/icons.svg']

gulp.task('svgstore', function () {
  return gulp
    .src(iconsource)
    .pipe(rename({prefix: 'svg-'}))
    .pipe(svgmin())
    .pipe(cheerio({
      run: function ($) {
        // remove green-screen color
        $('[fill="#023979"]').removeAttr('fill').parents('[fill="none"]').removeAttr('fill');
        $('[fill="#50E3C2"]').attr('fill', 'currentColor').parents('[fill="none"]').removeAttr('fill');
      },
      parserOptions: { xmlMode: true }
    }))
    .pipe(svgstore())
    .pipe(through2.obj(function (file, encoding, cb) {
      var $ = file.cheerio;
      var data = $('svg > symbol').map(function () {
        var viewBox = $(this).attr('viewBox').split(" ")
        return [
          '.'+ $(this).attr('id') + ' {' +
            ' width: ' + viewBox[2] + 'px;' +
            ' height: ' + viewBox[3] + 'px; ' +
          '}'
        ];
      }).get();
      var cssFile = new gutil.File({
        path: '_svg-dimensions.scss',
        contents: new Buffer(data.join("\n"))
      });
      this.push(cssFile);
      this.push(file);
      cb();
    }))
    .pipe(gulp.dest('src/scss/icons'));
});

gulp.task('default', function(){
  gulp.watch(iconsource, ['svgstore']);
});
