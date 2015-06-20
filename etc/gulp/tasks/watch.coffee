watch = require "gulp-watch"

module.exports = (gulp, config) -> ->
  gulp.watch config.cssPattern,    ["sass"]
  gulp.watch config.jadePattern,   ["jade"]
  gulp.watch config.jsPattern,     ["coffee"]
