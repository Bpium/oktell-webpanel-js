module.exports = (grunt)->
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
