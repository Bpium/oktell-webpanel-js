fs = require 'fs'

module.exports = (grunt) ->

	grunt.initConfig
		createbuildfolder:
			path: 'builds'
		insertfilesasvars:
			htmlminTaskName: 'templates'
			target: 'coffee/webpanel.coffee'
			dest: 'buildlast/webpanel.coffee'
			regexFind: /loadTemplate(?:\s*\(\s*|\s+)[\"\'](.+?)[\"\']\s*\)*/
			find: 'templates = {}'
			replace: 'templates = '

		includecoffee:
			main:
				target: 'buildlast/webpanel.coffee'
				dest: 'buildlast/webpanel.coffee'
				regexp: /\#includecoffee\s+(.+?)[ \r\n]+/
		htmlmin:
			templates:
				options:
					removeComments: true
					collapseWhitespace: true
				files: {} # set by insertfilesasvars:templates
		coffee:
			main:
				options:
					bare: true
				files:
					'buildlast/webpanel.js': 'buildlast/webpanel.coffee'
		cssmin:
			css:
				files:
					'buildlast/webpanel.min.css': 'css/webpanel.css'
		copy:
			css:
				files: [
					{ src: 'css/webpanel.css', dest: 'buildlast/', flatten: true, expand: true }
				]
			main:
				files: []
		uglify:
			main:
				files: { 'buildlast/webpanel.min.js': 'buildlast/webpanel.js' }
		clean:
			temp: ['temp/*']
			buildlast: ['buildlast/*']
		compress:
			main:
				options: {
					archive: 'buildlast/webpanel.zip'
					mode: 'zip'
					pretty: true
				},
				files: [{cwd: 'buildlast/', src: '*', dest: '', expand: true, filter: 'isFile', flatten: true}]

	grunt.loadNpmTasks 'grunt-contrib-htmlmin'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-cssmin'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-compress'

	grunt.registerTask 'build', ['clean:buildlast', 'createbuildfolder', 'insertfilesasvars', 'includecoffee', 'coffee', 'uglify', 'cssmin', 'copy:css', 'compress', 'copy:main', 'clean:temp']

	grunt.registerTask 'createbuildfolder', 'Create new folder in builds path with date in name', ->
		config = grunt.config.get this.name
		fs = require 'fs'
		moment = require 'moment'
		folder = config.path + '/' + moment().format('YYYY-MM-DD HH-mm-ss')
		fs.mkdirSync folder
		copyConf = grunt.config 'copy'
		copyConf.main.files.push
			dest: folder + '/'
			src: 'buildlast/*'
			flatten: true
			expand: true
		grunt.config 'copy', copyConf
		grunt.option 'buildFolder', folder
		console.log 'created folder ' +config.path + '/' + folder

	grunt.registerMultiTask 'includecoffee', 'Replace matched string by file', ->
		config = @data
		fs = require 'fs'
		file = fs.readFileSync(config.target).toString()
		files = []
		rAll = new RegExp config.regexp.source, 'gm'
		for f in file.match(rAll) or []
			m = f.match(config.regexp)
			if m
				files.push m
		files[i] = [ f[0], ( if f[1][0] is '/' then f[1].substr(1) else f[1] ) ] for f,i in files
		for f in files
			pos = file.indexOf f[0]
			pos--
			tabs = ''
			ch = file[pos]
			while ch is "\t"
				tabs += ch
				ch = file[--pos]
			file = file.replace f[0], f[0] + tabs + fs.readFileSync(f[1]).toString().replace(/(\r\n|\n)/g, "\n" + tabs) + "\r\n"
		fs.writeFileSync config.dest, file

	grunt.registerTask 'insertfilesasvars', 'Replace matched string by file', ->
		config = grunt.config.get this.name

		fs = require 'fs'
		file = fs.readFileSync(config.target).toString()
		files = config.files
		originalFileNames = config.originalFileNames or {}

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
					originalFileNames[f] = fNewName
				conf[config.htmlminTaskName].files = cf
				grunt.config 'htmlmin', conf
				grunt.task.run 'htmlmin:'+config.htmlminTaskName
				config.files = files
				config.originalFileNames = originalFileNames
				grunt.config this.name, config
				grunt.task.run 'insertfilesasvars'
				return

		replaceStr = '{'
		for k,f of originalFileNames
			replaceStr += if f then "'"+k+"':'"+ fs.readFileSync(f).toString().replace(/'/g, "\\'") + "', "
		replaceStr += '}'

		fs.writeFileSync config.dest, file.replace config.find , config.replace + replaceStr


