jsdom = require 'jsdom' 
fs = require 'fs'
_ = require 'underscore'

jsp = require("uglify-js").parser;
pro = require("uglify-js").uglify;

_.templateSettings = interpolate: /\{\{(.+?)\}\}/g

templates = {}
jsdom.env 
  html:'http://localhost:3000',
  src: fs.readFileSync('./builder/jquery.min.js', 'utf-8')
  done: (errors, window) ->
    $ = window.$
    console.log 'errors', errors
    $('script[type="html/template"]').each (k,_v) -> 
      v = $(_v)
      code = _.template(v.html()).toString().replace(/^function anonymous/, 'function t')
      ast = jsp.parse(code)
      ast = pro.ast_mangle(ast)
      ast = pro.ast_squeeze(ast)
      code = pro.gen_code(ast)
      templates[v.attr('id')] = code
    console.log JSON.stringify templates