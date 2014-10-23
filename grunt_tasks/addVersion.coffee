fs = require 'fs'

module.exports = (grunt)->
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
    config.comment = config.comment.replace('version', version ) # + '.' + build)
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
