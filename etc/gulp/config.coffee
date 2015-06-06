module.exports =
  coffee:
    dest: "www"
    src: "src/entry.coffee"
    targetFilename: "app.js"
    targetFilenameMin: "app.js"

  sass:
    dest: "www"
    src: "src/style.sass"
    targetFilename: "style.css"
    targetFilenameMin: "style.css"

  jade:
    dest: "www"
    src: "src/**/*.jade"
    targetFilename: "templates.js"
    targetFilenameMin: "templates.js"

  watch:
    jsPattern: "src/**/*.coffee"
    cssPattern: "src/**/*.{sass,scss}"
    jadePattern: "src/**/*.jade"

  docs:
    hostname: "http://localhost:8000"
    backend:
      dest: "docs/backend"
      src: "src/server/**/*.coffee"
    frontend:
      dest: "docs/frontend"
      src: "src/javascripts/**/*.coffee"

  bower:
    dest: "www"
    targetFilename: "libraries.js"
