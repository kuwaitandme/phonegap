require('coffee-script/register');

var gulp = require('./gulp')([
	'coffee',
	'jade',
	'sass',
	'bower',
	'watch'
]);

gulp.task('css', ['sass']);
gulp.task('html', ['jade']);
gulp.task('js', ['coffee']);


gulp.task('build', ['js', 'css', 'html', 'bower']);
gulp.task('default',['build', 'watch']);