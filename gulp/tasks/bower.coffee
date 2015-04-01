concat         = require 'gulp-concat'
mainBowerFiles = require 'main-bower-files'
gulpIgnore     = require 'gulp-ignore'

module.exports = (gulp, config) ->
	gulp.task 'bower', ->
		gulp.src mainBowerFiles()
		.pipe gulpIgnore.include '*.js'
		.pipe concat    config.targetFilename
		.pipe gulp.dest config.dest