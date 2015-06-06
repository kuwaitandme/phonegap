"use strict";

require("coffee-script/register");

var dependencies = [
  "coffee",
  "docs",
  "jade",
  "bower",
  "sass",
  "watch"
];

var gulp = require("./etc/gulp")(dependencies);


gulp.task("css", ["sass"]);
gulp.task("css:minified", ["sass:minified"]);
gulp.task("html", ["jade"]);
gulp.task("js", ["coffee"]);
gulp.task("js:minified", ["coffee:minified"]);

gulp.task("minify", ["js:minified", "css:minified"]);
gulp.task("build", ["js", "css", "html", "bower"]);

gulp.task("default", ["build", "watch"]);
