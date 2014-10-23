module.exports = (grunt)->
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
