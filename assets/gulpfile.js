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

var cssEntryPath = 'css/app.scss';

var cssWatchPaths = [
  'css/**/*.css*',
  'css/**/*.scss*',
];

var jsEntryPath = 'js/app.js';

var jsWatchPaths = [
  'deps/phoenix/priv/static/phoenix.js',
  'deps/phoenix_html/priv/static/phoenix_html.js',
  'js/**/*.js*',
  'vendor/**/*.js*',
];

var assetPaths = [
  'static/**/*',
];

// ==================TASKS=====================

function printError ( err ) {
  gutil.log(
    gutil.colors.red( "[Error]" ), err.message
  );
}

gulp.task('css-app', function() {
  return gulp
    .src( cssEntryPath )
    .pipe( concat('app.scss') )
    .pipe( sass( { importer: moduleImporter() } ).on('error', sass.logError ) )
    .pipe( gutil.env.env === 'production' ? cleanCSS() : gutil.noop() )
    .on( "error", printError )
    .pipe( gulp.dest('priv/static/css') )
});

gulp.task('js-app', function() {
  return gulp
    .src( jsEntryPath )
    .pipe( browserify( { debug: gutil.env.env !== 'production' } ) )
    .on( "error", printError )
    .pipe( babel({presets: ['es2015']}) )
    .on( "error", printError )
    .pipe( concat('app.js') )
    .pipe( gutil.env.env === 'production' ? uglify() : gutil.noop() )
    .on( "error", printError )
    .pipe( gulp.dest('priv/static/js') )
});

gulp.task('assets', function() {
  return gulp
    .src( assetPaths )
    .on( "error", printError )
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

