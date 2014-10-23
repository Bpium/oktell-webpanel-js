// Generated by CoffeeScript 1.8.0
(function() {
  var fs;

  fs = require('fs');

  module.exports = function(grunt) {
    return grunt.registerMultiTask('addVersion', 'Add version to file names and to file content', function() {
      var build, config, content, fName, file, fileExt, files, path, pos, version, versionArr, _i, _len;
      config = this.data;
      files = grunt.file.expand({
        filter: 'isFile'
      }, config.fileNames);
      versionArr = grunt.file.read(config.versionFile).toString().split('.');
      version = versionArr.slice(0, 3).join('.');
      build = versionArr[3] || '1000';
      build = parseInt(build);
      build++;
      if (config.replace) {
        config.replace = config.replace.replace('version', version);
      }
      config.comment = config.comment.replace('version', version);
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        console.log(file);
        pos = file.lastIndexOf('/');
        fName = file.substr(pos + 1);
        path = file.substr(0, pos);
        content = grunt.file.read(file);
        fileExt = file.substr(file.lastIndexOf('.') + 1);
        if (fileExt === 'coffee') {
          content = '# ' + config.comment + "\n\n" + content;
        } else if (fileExt === 'html' || fileExt === 'html') {
          content = '<!-- ' + config.comment + " -->/\n" + content;
        } else {
          content = '/* ' + config.comment + " */\n\n" + content;
        }
        grunt.file.write(file, content);
        if (config.find && config.replace) {
          fs.renameSync(file, path + '/' + fName.replace(config.find, config.replace));
        }
      }
      return grunt.file.write(config.versionFile, version + '.' + build);
    });
  };

}).call(this);
