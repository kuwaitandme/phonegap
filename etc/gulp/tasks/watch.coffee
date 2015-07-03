runSequence = require "run-sequence"


module.exports = (gulp, config) -> ->
  gulp.task "watch-sass", (callback) -> runSequence "sass", "run", callback
  gulp.watch config.cssPattern,         ["watch-sass"]

  gulp.task "watch-jade", (callback) -> runSequence "jade", "run", callback
  gulp.watch config.jadePattern,        ["watch-jade"]

  gulp.task "watch-coffee", (callback) -> runSequence "coffee", "run", callback
  gulp.watch config.jsPattern,          ["watch-coffee"]

  gulp.task "watch-templates", (callback) ->
    runSequence "templates", "run", callback
  gulp.watch config.templatesPattern,   ["watch-templates"]