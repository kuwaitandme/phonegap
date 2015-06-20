require("coffee-script/register");
var runSequence = require("run-sequence");

var dependencies = [
  "bower",
  // "docs",
  "coffee",
  "jade",
  "sass",
  "watch"
];


var gulp = require("./etc/gulp")(dependencies);

// gulp.task("build", ["coffee", "sass", "jade", "bower"]);
gulp.task("build", ["coffee", "sass", "jade"]);

gulp.task("default", function (callback) {
  runSequence(
    "build",
    "watch",
    callback);
});

