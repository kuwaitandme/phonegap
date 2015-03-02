module.exports = function (grunt) {
	"use strict";

	grunt.initConfig({

		/*! JS browserify options */
		browserify: {
			app: {
				dest: "www/app.js",
				src: "javascripts/entry.js",
				options: {
					basedir: "javascripts/",
					browserifyOptions : { debug: true, }
				},
			}
		},

		/*! Compile and Minify the SASS files. */
		sass: {
			style: {
				files: {
					'www/style.css' : 'assets/stylesheets/style.scss'
				},
				options: { style: 'compressed' },
			},
		},


		/*! Grunt watch rules */
		watch: {
			css: {
				files: ['assets/**/*.scss'],
				options: { livereload: true },
				tasks: ['css']
			},
			html: {
				files: ['assets/**/*.jade'],
				tasks: ['html']
			},
			js: {
				files: ["assets/**/*.js"],
				tasks: ["js"]
			}
		},

		exec: {
			index: 'jade assets/jade/pages/* -P --out ./www/',
			// index: 'jade assets/jade/pages/auth/* -P --out ./www/html/auth',
			// index: 'jade assets/jade/pages/classified/* -P --out ./www/html/classified',
			// index: 'jade assets/jade/pages/guest/* -P --out ./www/html/guest',
			// index: 'jade assets/jade/pages/auth/* -P --out ./www/html/auth',
		},
	});

	/*! Load grunt modules */
	grunt.loadNpmTasks("grunt-browserify");
	grunt.loadNpmTasks("grunt-contrib-sass");
	grunt.loadNpmTasks('grunt-contrib-sass');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-exec');

	/*! Custom Grunt task definitions */
	grunt.registerTask('css', 'Compiles the CSS files', function() {
		grunt.task.run(['sass']);
	});
	grunt.registerTask('html', 'Compiles the HTML files', function() {
		grunt.task.run(['exec']);
	});
	grunt.registerTask("js", "Compiles the JS files", function() {
		grunt.task.run(["browserify"]);
	});

	/*! Set default grunt task */
	grunt.registerTask('default', ['css', 'html', 'js']);
};
