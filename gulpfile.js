require('coffee-script/register');

var gulp = require('./gulp')([
	'coffee',
	'jade',
	'sass',
	'watch'
]);

gulp.task('css', ['sass']);
gulp.task('html', ['jade']);
gulp.task('js', ['coffee']);


gulp.task('build', ['js', 'css']);
gulp.task('default',['build', 'watch']);