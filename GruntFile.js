// Generated by CoffeeScript 1.8.0
(function() {
  var fs, _;

  fs = require('fs');

  _ = require('lodash');

  module.exports = function(grunt) {
    require('load-grunt-tasks')(grunt);
    require('time-grunt')(grunt);
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
        build: {
          files: [
            {
              src: ['buildlast/*.css', 'buildlast/*.js'],
              dest: 'build',
              flatten: true,
              expand: true
            }
          ]
        },
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
        build: ['build/*'],
        buildlast: ['buildlast/*']
      },
      compress: {
        main: {
          options: {
            archive: 'buildlast/oktell-panel.js-' + grunt.file.read('version.json').toString().split('.').slice(0, 3).join('.') + '.zip',
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
            archive: 'buildlast/oktell-panel.js-' + grunt.file.read('version.json').toString().split('.').slice(0, 3).join('.') + '.zip',
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
          replace: '$1-version$2',
          comment: 'Oktell-panel.js version http://js.oktell.ru/webpanel',
          versionFile: 'version.json'
        },
        build: {
          fileNames: ['build/*'],
          comment: 'Oktell-panel.js version http://js.oktell.ru/webpanel',
          versionFile: 'version.json'
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
            'buildlast/oktell-panel.css': ['css/oktell-panel.css', 'css/test.css', 'css/jquery.jscrollpane.css']
          }
        }
      },
      connect: {
        site: {
          options: {
            hostname: 'localhost',
            port: 9002,
            base: '',
            keepalive: true
          }
        }
      }
    });
    grunt.loadTasks('./grunt_tasks');
    grunt.registerTask('build', ['clean:buildlast', 'clean:build', 'insertfilesasvars', 'includecoffee', 'coffee', 'concat:js', 'uglify', 'concat:css', 'cssmin', 'copy:build', 'addVersion', 'clean:temp', 'clean:buildlast']);
    return grunt.registerTask('default', ['build']);
  };

}).call(this);
