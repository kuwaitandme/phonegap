jade      = require "gulp-jade"


module.exports = (gulp, config) -> ->
  gulp.src config.src
  .pipe jade pretty: true
  .pipe gulp.dest config.dest
