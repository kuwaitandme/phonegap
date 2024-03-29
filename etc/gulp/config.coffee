module.exports =
  coffee:
    dest: "www/build"
    src: [
      "src/app.coffee"
      "src/autoupdater.coffee"
      "src/bootstrap.coffee"
    ]

  sass:
    dest: "www/build"
    src: "src/style.sass"
    targetFilename: "style.css"
    targetFilenameMin: "style.css"

  jade:
    dest: "www/"
    src: "src/index.jade"

  templates:
    dest: "www/build"
    src: "src/**/*.jade"
    targetFilename: "templates.js"
    targetFilenameMin: "templates.js"

  watch:
    jsPattern: "src/**/*.coffee"
    cssPattern: "src/**/*.{sass,scss}"
    jadePattern: "src/index.jade"
    templatesPattern: "src/**/*.jade"

  docs:
    hostname: "http://localhost:8000"
    backend:
      dest: "docs/backend"
      src: "src/server/**/*.coffee"
    frontend:
      dest: "docs/frontend"
      src: "src/javascripts/**/*.coffee"

  bower:
    dest: "www/build"
    targetFilename: "libraries.js"

  run:
    cmd: "npm run-script post-gulp"