// Generated by CoffeeScript 1.8.0
(function() {
  module.exports = function(grunt) {
    return grunt.registerTask('createbuildfolder', 'Create new folder in builds path with date in name', function() {
      var config, copyConf, folder, fs, moment;
      config = grunt.config.get(this.name);
      fs = require('fs');
      moment = require('moment');
      folder = config.path + '/' + moment().format('YYYY-MM-DD HH-mm-ss');
      fs.mkdirSync(folder);
      copyConf = grunt.config('copy');
      copyConf.main.files.push({
        dest: folder + '/',
        src: 'buildlast/*',
        flatten: true,
        expand: true
      });
      grunt.config('copy', copyConf);
      grunt.option('buildFolder', folder);
      return console.log('created folder ' + config.path + '/' + folder);
    });
  };

}).call(this);
