concat         = require 'gulp-concat'
mainBowerFiles = require 'main-bower-files'

module.exports = (gulp, config) ->
	gulp.task 'bower', ->
		gulp.src mainBowerFiles()
		.pipe concat    config.targetFilename
		.pipe gulp.dest config.dest