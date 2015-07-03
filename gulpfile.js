require("coffee-script/register");
var runSequence = require("run-sequence");

var dependencies = [
  "bower",
  "coffee",
  "jade",
  "run",
  "sass",
  "templates",
  "watch"
  // "docs",
];


var gulp = require("./etc/gulp")(dependencies);


gulp.task("build", function (callback) {
  runSequence(
    ["coffee", "sass", "jade", "templates"],
    "run",
    callback);
});


gulp.task("default", function (callback) {
  runSequence(
    "build",
    "watch",
    callback);
});

