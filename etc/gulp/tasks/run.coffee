run = require "gulp-run"


module.exports = (gulp, config) -> ->
  run config.cmd
  .exec()