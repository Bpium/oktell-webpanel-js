fs = require 'fs'

module.exports = (grunt) ->

	grunt.initConfig
		createbuildfolder:
			path: 'build'
		insertfilesasvars:
			htmlminTaskName: 'templates'
			target: 'coffee/webpanel.coffee'
			dest: 'build/last/webpanel.coffee'
			regexFind: /loadTemplate(?:\s*\(\s*|\s+)[\"\'](.+?)[\"\']\s*\)*/
			find: 'templates = {}'
			replace: 'templates = '
		htmlmin:
			templates:
				options:
					removeComments: true
					collapseWhitespace: true
				files: {} # set by insertfilesasvars
		coffee:
			main:
				options:
					bare: true
				files:
					'build/last/webpanel.js': 'build/last/webpanel.coffee'
		cssmin:
			css:
				files:
					'build/last/webpanel.min.css': 'css/webpanel.css'
		copy:
			main:
				files: [
					src: 'css/webpanel.css'
					dest: 'build/last/'
					filter: 'isFile'
				]
		uglify:
			main:
				'build/last/webpanel.min.js': 'build/last/webpanel.js'
		clean: ['temp/*', 'build/last/*']
		compress:
			main:
				options: {
					archive: 'build/last/webpanel.zip'
					mode: 'zip'
					pretty: true
				},
				files: [{src: ['build/last/*'], dest: 'build/last/webpanel.zip'}]

	grunt.loadNpmTasks 'grunt-contrib-htmlmin'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-cssmin'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-compress'

	grunt.registerTask 'build', ['createbuildfolder', 'insertfilesasvars', 'coffee', 'uglify', 'cssmin', 'compress', 'copy', 'clean' ]

	grunt.registerTask 'createbuildfolder', 'Create new folder in builds path with date in name', ->
		config = grunt.config.get this.name
		fs = require 'fs'
		moment = require 'moment'
		folder = config.path + '/' + moment().format('YYYY-MM-DD HH-mm-ss')
		fs.mkdirSync folder
		copyConf = grunt.config 'copy'
		copyConf.main.files.push
			dest: folder + '/'
			src: 'build/last/*'
			flatten: true
		grunt.config 'copy', copyConf
		grunt.option 'buildFolder', folder

	grunt.registerTask 'insertfilesasvars', 'Replace matcged string by file', ->
		config = grunt.config.get this.name

		fs = require 'fs'
		file = fs.readFileSync(config.target).toString()
		files = config.files
		console.log 'FILES' + config.files
		if not files
			files = []
			rAll = new RegExp config.regexFind.source, 'gm'
			files.push f.match(config.regexFind)?[1] for f in file.match rAll
			files[i] = ( if f[0] is '/' then f.substr(1) else f ) for f,i in files

			if config.htmlminTaskName
				conf = grunt.config.get 'htmlmin'
				cf = {}
				for f,i in files
					fName = f.split('/')[f.split('/').length-1]
					fNewName = 'temp/'+ fName.replace('.', '_' + Date.now() + '.')
					cf[fNewName] = f
					files[i] = fNewName
				conf[config.htmlminTaskName].files = cf
				grunt.config 'htmlmin', conf
				grunt.task.run 'htmlmin:'+config.htmlminTaskName
				config.files = files
				grunt.config this.name, config
				grunt.task.run 'insertfilesasvars'
				return


		replaceStr = '{'
		for f in files
			replaceStr += if f then "'"+f+"':'"+ fs.readFileSync(f).toString().replace(/'/g, "\\'") + "', "
		replaceStr += '}'

		fs.writeFileSync config.dest, file.replace config.find , config.replace + replaceStr


