concat    = require "gulp-concat"
jade      = require "gulp-jade"
rename    = require "gulp-rename"
template  = require "gulp-lodash-template"


module.exports = (gulp, config) -> ->
  gulp.src config.src
  .pipe jade()
  .pipe template
    name: (file) -> (file.relative.split ".html")[0]
    namespace: "JST"
  .pipe concat config.targetFilename
  .pipe gulp.dest config.dest