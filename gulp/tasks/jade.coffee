jade      = require 'gulp-jade'
rename    = require 'gulp-rename'
concat    = require 'gulp-concat'
template  = require 'gulp-template-compile'

module.exports = (gulp, config) ->
	gulp.task 'jade', ->
		gulp.src config.src
		.pipe jade pretty: true
		.pipe template namespace: 'template'
		.pipe concat config.targetFilename
		.pipe gulp.dest config.dest