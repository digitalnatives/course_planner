// Contains support for: SASS/SCSS, concatenation, and minification for JS and CSS

var gulp = require('gulp');
var gutil = require('gulp-util');

var sass = require('gulp-sass');
var moduleImporter = require('sass-module-importer');
var cleanCSS = require('gulp-clean-css');

var babel = require('gulp-babel');
var browserify = require('gulp-browserify');
var uglify = require('gulp-uglify');

var concat = require('gulp-concat');



function reportChange ( event ) {
  console.log('[gulp] File ' + event.path + ' was ' + event.type );
}

// ==================PATHS=====================

var cssEntryPath = 'web/static/css/app.scss';

var cssWatchPaths = [
  'web/static/css/**/*.css*',
  'web/static/css/**/*.scss*',
];

var jsEntryPath = 'web/static/js/app.js';

var jsWatchPaths = [
  'deps/phoenix/priv/static/phoenix.js',
  'deps/phoenix_html/priv/static/phoenix_html.js',
  'web/static/js/**/*.js*',
  'web/static/vendor/**/*.js*',
];

var assetPaths = [
  'web/static/assets/**/*',
];

// ==================TASKS=====================

gulp.task('css-app', function() {
  return gulp
    .src( cssEntryPath )
    .pipe( concat('app.scss') )
    .pipe( sass( { importer: moduleImporter() } ).on('error', sass.logError ) )
    .pipe( gutil.env.env === 'production' ? cleanCSS() : gutil.noop() )
    .on( "error",
      function ( err ) {
        gutil.log(
          gutil.colors.red( "[Error]" ), JSON.stringify( err, 0, 2 )
        );
      }
    )
    .pipe( gulp.dest('priv/static/css') )
});

gulp.task('js-app', function() {
  return gulp
    .src( jsEntryPath )
    .pipe( browserify( { debug: gutil.env.env !== 'production' } ) )
    .pipe( babel({presets: ['es2015']}) )
    .pipe( concat('app.js') )
    .pipe( gutil.env.env === 'production' ? uglify() : gutil.noop() )
    .on( "error",
      function ( err ) {
        gutil.log(
          gutil.colors.red( "[Error]" ), JSON.stringify( err, 0, 2 )
        );
      }
    )
    .pipe( gulp.dest('priv/static/js') )
});

gulp.task('assets', function() {
  return gulp
    .src( assetPaths )
    .on( "error",
      function ( err ) {
        gutil.log(
          gutil.colors.red( "[Error]" ), JSON.stringify( err, 0, 2 )
        );
      }
    )
    .pipe( gulp.dest('priv/static') );
});

// ================== ROOT TASKS =====================

gulp.task('default', [
  'css-app',
  'js-app',
  'assets',
]);

gulp.task( 'watch',
  function ( ) {
    // CSS / SASS
    gulp.watch(cssWatchPaths, ['css-app']).on('change', reportChange);

    // JS
    gulp.watch(jsWatchPaths, ['js-app']).on('change', reportChange);

    // Other assets
    gulp.watch(assetPaths, ['assets']).on('change', reportChange);
  }
);

