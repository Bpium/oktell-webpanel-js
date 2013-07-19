// Generated by CoffeeScript 1.6.2
var fs, _;

fs = require('fs');

_ = require('lodash');

module.exports = function(grunt) {
  grunt.initConfig({
    createbuildfolder: {
      path: 'builds'
    },
    insertfilesasvars: {
      htmlminTaskName: 'templates',
      target: 'coffee/oktell-panel.coffee',
      dest: 'temp/oktell-panel-cf.coffee',
      regexFind: /loadTemplate(?:\s*\(\s*|\s+)[\"\'](.+?)[\"\']\s*\)*/,
      find: 'templates = {}',
      replace: 'templates = '
    },
    includecoffee: {
      main: {
        target: 'temp/oktell-panel-cf.coffee',
        dest: 'temp/oktell-panel-cf.coffee',
        regexp: /\#includecoffee\s+(.+?)[ \r\n]+/
      }
    },
    htmlmin: {
      templates: {
        options: {
          removeComments: true,
          collapseWhitespace: true
        },
        files: {}
      }
    },
    coffee: {
      main: {
        options: {
          bare: true
        },
        files: {
          'buildlast/oktell-panel.js': 'temp/oktell-panel-cf.coffee'
        }
      }
    },
    cssmin: {
      css: {
        files: {
          'buildlast/oktell-panel.min.css': ['buildlast/oktell-panel.css']
        }
      }
    },
    copy: {
      css: {
        files: [
          {
            src: 'css/oktell-panel.css',
            dest: 'buildlast/',
            flatten: true,
            expand: true
          }
        ]
      },
      main: {
        files: []
      }
    },
    uglify: {
      main: {
        files: {
          'buildlast/oktell-panel.min.js': ['buildlast/oktell-panel.js']
        }
      }
    },
    clean: {
      temp: ['temp/*'],
      buildlast: ['buildlast/*']
    },
    compress: {
      main: {
        options: {
          archive: 'buildlast/oktell-panel.js-' + grunt.file.read('version.json') + '.zip',
          mode: 'zip',
          pretty: true
        },
        files: [
          {
            cwd: 'buildlast/',
            src: '*',
            dest: '',
            expand: true,
            filter: 'isFile',
            flatten: true
          }
        ]
      },
      jsfiles: {
        options: {
          archive: 'buildlast/oktell-panel.js-' + grunt.file.read('version.json') + '.zip',
          mode: 'zip',
          pretty: true
        },
        files: [
          {
            cwd: 'buildlast/',
            src: '*',
            dest: '',
            expand: true,
            filter: 'isFile',
            flatten: true
          }
        ]
      }
    },
    addVersion: {
      panel: {
        fileNames: ['buildlast/*.coffee', 'buildlast/*.js', 'buildlast/*.css'],
        find: /^(oktell-panel)(.+)/,
        replace: '$1-' + grunt.file.read('version.json') + '$2',
        comment: 'Oktell-panel.js ' + grunt.file.read('version.json') + " http://js.oktell.ru/webpanel"
      }
    },
    concat: {
      js: {
        files: {
          'buildlast/oktell-panel.js': ['js/jquery.mousewheel.js', 'js/mwheelIntent.js', 'js/jquery.jscrollpane.js', 'buildlast/oktell-panel.js']
        }
      },
      css: {
        files: {
          'buildlast/oktell-panel.css': ['css/oktell-panel.css', 'css/jquery.jscrollpane.css']
        }
      }
    }
  });
  grunt.loadNpmTasks('grunt-contrib-htmlmin');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-compress');
  grunt.registerTask('build', ['clean:buildlast', 'insertfilesasvars', 'includecoffee', 'coffee', 'concat:js', 'uglify', 'concat:css', 'cssmin', 'addVersion', 'compress', 'clean:temp']);
  grunt.registerTask('default', ['build']);
  grunt.registerMultiTask('addVersion', 'Add version to file names and to file content', function() {
    var config, content, fName, file, fileExt, files, path, pos, _i, _len, _results;

    config = this.data;
    files = grunt.file.expand({
      filter: 'isFile'
    }, config.fileNames);
    _results = [];
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      file = files[_i];
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
      _results.push(fs.renameSync(file, path + '/' + fName.replace(config.find, config.replace)));
    }
    return _results;
  });
  grunt.registerTask('createbuildfolder', 'Create new folder in builds path with date in name', function() {
    var config, copyConf, folder, moment;

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
  grunt.registerMultiTask('includecoffee', 'Replace matched string by file', function() {
    var ch, config, f, file, files, i, m, pos, rAll, tabs, _i, _j, _k, _len, _len1, _len2, _ref;

    config = this.data;
    fs = require('fs');
    file = fs.readFileSync(config.target).toString();
    files = [];
    rAll = new RegExp(config.regexp.source, 'gm');
    _ref = file.match(rAll) || [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      f = _ref[_i];
      m = f.match(config.regexp);
      if (m) {
        files.push(m);
      }
    }
    for (i = _j = 0, _len1 = files.length; _j < _len1; i = ++_j) {
      f = files[i];
      files[i] = [f[0], (f[1][0] === '/' ? f[1].substr(1) : f[1])];
    }
    for (_k = 0, _len2 = files.length; _k < _len2; _k++) {
      f = files[_k];
      pos = file.indexOf(f[0]);
      pos--;
      tabs = '';
      ch = file[pos];
      while (ch === "\t") {
        tabs += ch;
        ch = file[--pos];
      }
      file = file.replace(f[0], f[0] + tabs + fs.readFileSync(f[1]).toString().replace(/(\r\n|\n)/g, "\n" + tabs) + "\r\n");
    }
    return fs.writeFileSync(config.dest, file);
  });
  return grunt.registerTask('insertfilesasvars', 'Replace matched string by file', function() {
    var cf, conf, config, f, fName, fNewName, file, files, i, k, originalFileNames, rAll, replaceStr, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;

    config = grunt.config.get(this.name);
    fs = require('fs');
    file = fs.readFileSync(config.target).toString();
    files = config.files;
    originalFileNames = config.originalFileNames || {};
    if (!files) {
      files = [];
      rAll = new RegExp(config.regexFind.source, 'gm');
      _ref = file.match(rAll);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        f = _ref[_i];
        files.push((_ref1 = f.match(config.regexFind)) != null ? _ref1[1] : void 0);
      }
      for (i = _j = 0, _len1 = files.length; _j < _len1; i = ++_j) {
        f = files[i];
        files[i] = (f[0] === '/' ? f.substr(1) : f);
      }
      if (config.htmlminTaskName) {
        conf = grunt.config.get('htmlmin');
        cf = {};
        for (i = _k = 0, _len2 = files.length; _k < _len2; i = ++_k) {
          f = files[i];
          fName = f.split('/')[f.split('/').length - 1];
          fNewName = 'temp/' + fName.replace('.', '_' + Date.now() + '.');
          cf[fNewName] = f;
          originalFileNames[f] = fNewName;
        }
        conf[config.htmlminTaskName].files = cf;
        grunt.config('htmlmin', conf);
        grunt.task.run('htmlmin:' + config.htmlminTaskName);
        config.files = files;
        config.originalFileNames = originalFileNames;
        grunt.config(this.name, config);
        grunt.task.run('insertfilesasvars');
        return;
      }
    }
    replaceStr = '{';
    for (k in originalFileNames) {
      f = originalFileNames[k];
      replaceStr += f ? "'" + k + "':'" + fs.readFileSync(f).toString().replace(/'/g, "\\'") + "', " : void 0;
    }
    replaceStr += '}';
    return fs.writeFileSync(config.dest, file.replace(config.find, config.replace + replaceStr));
  });
};
