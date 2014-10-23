module.exports = (grunt)->
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
