sass      = require 'gulp-sass'
rename    = require 'gulp-rename'
uglifycss = require 'gulp-uglifycss'

module.exports = (gulp, config) ->
	gulp.task 'sass', ->
		gulp.src config.src
		.pipe sass
			errLogToConsole: true
			sourceComments: 'map'
		.pipe rename config.targetFilename
		.pipe gulp.dest config.dest