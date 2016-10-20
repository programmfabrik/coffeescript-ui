var gulp = require('gulp');
var gutil = require('gulp-util');
var rename = require('gulp-rename');
var svgstore = require('gulp-svgstore');
var svgmin = require('gulp-svgmin');
var cheerio = require('gulp-cheerio');
var through2 = require('through2');

var iconsource = 'src/scss/icons/*.svg';

gulp.task('svgstore', function () {
  return gulp
    .src(iconsource)
    .pipe(rename({prefix: 'svg-'}))
    .pipe(svgmin())
    .pipe(cheerio({
      run: function ($) {
        // remove green-screen color
        $('[fill="#F6A623"]').removeAttr('fill').parents('[fill="none"]').removeAttr('fill');
        $('[fill="#7ED321"]').attr('fill', 'currentColor').parents('[fill="none"]').removeAttr('fill');
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
        path: 'css/svg-dimensions.css',
        contents: new Buffer(data.join("\n"))
      });
      this.push(cssFile);
      this.push(file);
      cb();
    }))
    .pipe(gulp.dest('build'));
});

gulp.task('default', function(){
  gulp.watch(iconsource, ['svgstore']);
});