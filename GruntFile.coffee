fs = require 'fs'
_ = require 'lodash'

module.exports = (grunt) ->

	grunt.initConfig
		createbuildfolder:
			path: 'builds'
		insertfilesasvars:
			htmlminTaskName: 'templates'
			target: 'coffee/oktell-panel.coffee'
			dest: 'temp/oktell-panel-cf.coffee'
			regexFind: /loadTemplate(?:\s*\(\s*|\s+)[\"\'](.+?)[\"\']\s*\)*/
			find: 'templates = {}'
			replace: 'templates = '

		includecoffee:
			main:
				target: 'temp/oktell-panel-cf.coffee'
				dest: 'temp/oktell-panel-cf.coffee'
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
					'buildlast/oktell-panel.js': 'temp/oktell-panel-cf.coffee'
		cssmin:
			css:
				files:
					'buildlast/oktell-panel.min.css': ['buildlast/oktell-panel.css']
		copy:
			build:
				files: [{
					src: ['buildlast/*.css', 'buildlast/*.js']
					dest: 'build'
					flatten: true
					expand: true
				}]
			css:
				files: [
					{ src: 'css/oktell-panel.css', dest: 'buildlast/', flatten: true, expand: true }
				]
			main:
				files: []
		uglify:
			main:
				files: { 'buildlast/oktell-panel.min.js': ['buildlast/oktell-panel.js'] }
		clean:
			temp: ['temp/*']
			build: ['build/*']
			buildlast: ['buildlast/*']
		compress:
			main:
				options: {
					archive: 'buildlast/oktell-panel.js-' + grunt.file.read('version.json').toString().split('.').slice(0,3).join('.') + '.zip'
					mode: 'zip'
					pretty: true
				},
				files: [{cwd: 'buildlast/', src: '*', dest: '', expand: true, filter: 'isFile', flatten: true}]
			jsfiles:
				options: {
					archive: 'buildlast/oktell-panel.js-' + grunt.file.read('version.json').toString().split('.').slice(0,3).join('.') + '.zip'
					mode: 'zip'
					pretty: true
				},
				files: [{cwd: 'buildlast/', src: '*', dest: '', expand: true, filter: 'isFile', flatten: true}]
		addVersion:
			panel:
				fileNames: ['buildlast/*.coffee', 'buildlast/*.js', 'buildlast/*.css']
				find: /^(oktell-panel)(.+)/
				replace:  '$1-version$2'
				comment: 'Oktell-panel.js version http://js.oktell.ru/webpanel'
				versionFile: 'version.json'
			build:
				fileNames: ['build/*']
				comment: 'Oktell-panel.js version http://js.oktell.ru/webpanel'
				versionFile: 'version.json'

		concat:
			js:
				files: { 'buildlast/oktell-panel.js': ['js/jquery.mousewheel.js', 'js/mwheelIntent.js', 'js/jquery.jscrollpane.js', 'buildlast/oktell-panel.js'] }
			css:
				files: { 'buildlast/oktell-panel.css': ['css/oktell-panel.css', 'css/test.css', 'css/jquery.jscrollpane.css'] }

	grunt.loadNpmTasks 'grunt-contrib-htmlmin'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-cssmin'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadNpmTasks 'grunt-contrib-compress'

	grunt.registerTask 'build', ['clean:buildlast', 'clean:build', 'insertfilesasvars', 'includecoffee', 'coffee', 'concat:js', 'uglify', 'concat:css', 'cssmin', 'copy:build', 'addVersion', 'compress', 'clean:temp']
	#grunt.registerTask 'build', ['clean:buildlast', 'createbuildfolder', 'insertfilesasvars', 'includecoffee', 'coffee', 'uglify', 'cssmin', 'copy:css', 'addVersion', 'compress', 'copy:main', 'clean:temp']

	grunt.registerTask 'default', ['build']

	grunt.registerMultiTask 'addVersion', 'Add version to file names and to file content', ->
		config = @data
		files = grunt.file.expand {filter:'isFile'}, config.fileNames
		versionArr = grunt.file.read(config.versionFile).toString().split('.')
		version = versionArr.slice(0,3).join('.')
		build = versionArr[3] or '1000'
		build = parseInt build
		build++
		if config.replace
			config.replace = config.replace.replace('version', version)
		config.comment = config.comment.replace('version', version + '.' + build)
		for file in files
			console.log file
			pos = file.lastIndexOf '/'
			fName = file.substr(pos+1)
			path = file.substr(0, pos)
			content = grunt.file.read(file)
			fileExt = file.substr(file.lastIndexOf('.') + 1)
			if fileExt is 'coffee'
				content = '# ' + config.comment + "\n\n" + content
			else if fileExt is 'html' or fileExt is 'html'
				content = '<!-- ' + config.comment + " -->/\n" + content
			else
				content = '/* ' + config.comment + " */\n\n" + content
			grunt.file.write file, content
			if config.find and config.replace
				fs.renameSync file, path + '/' + fName.replace( config.find, config.replace )
		grunt.file.write config.versionFile, version + '.' + build


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


