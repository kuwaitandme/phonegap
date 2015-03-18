coffee    = require 'gulp-coffee'
coffeeify = require 'gulp-coffeeify'
gutil     = require 'gulp-util'
rename    = require 'gulp-rename'
uglify    = require 'gulp-uglifyjs'

module.exports = (gulp, config) ->
	gulp.task 'coffee', ->
		gulp.src config.src
		.pipe (coffeeify options: debug: true).on('error', gutil.log)
		.pipe rename config.targetFilename
		.pipe gulp.dest config.dest