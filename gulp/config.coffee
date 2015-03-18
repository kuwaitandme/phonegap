module.exports =
	coffee:
		dest:              'www'
		src:               'assets/javascripts/entry.coffee'
		targetFilename:    'app.js'

	sass:
		dest:              './www'
		src:               'assets/stylesheets/style.scss'
		targetFilename:    'style.css'

	jade:
		dest:              'www'
		src:               'assets/jade/pages/*.jade'
		targetFilename:    'template.js'

	watch:
		jsPattern:         'assets/javascripts/**/*.coffee'
		cssPattern:        'assets/stylesheets/**/*.scss'
		jadePattern:       'assets/jade/**/*.jade'

	bower:
		dest:              'www'
		targetFilename:    'libraries.js'