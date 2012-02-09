_ = require 'underscore'
ck = require 'coffeekup'
fs = require 'fs'
{join} = require 'path'
jsp = require("uglify-js").parser
pro = require("uglify-js").uglify

_.templateSettings =
  evaluate    : /<%([\s\S]+?)%>/g
  interpolate : /<%=([\s\S]+?)%>/g
  escape      : /<%-([\s\S]+?)%>/g
  
template = (str, data) ->
  c = _.templateSettings
  tmpl = "var __p=[],print=function(){__p.push.apply(__p,arguments);};" + 
    "with(obj||{}){__p.push('" + 
    str.replace(/\\/g, "\\\\")
       .replace(/'/g, "\\'")
       .replace(c.escape or noMatch, (match, code) -> "',_.escape(" + unescape(code) + "),'")
       .replace(c.interpolate or noMatch, (match, code) -> "'," + unescape(code) + ",'")
       .replace(c.evaluate or noMatch, (match, code) -> "');" + unescape(code)
       .replace(/[\r\n\t]/g, " ") + ";__p.push('")
       .replace(/\r/g, "\\r")
       .replace(/\n/g, "\\n")
       .replace(/\t/g, "\\t") + "');}return __p.join('');"
  return new Function('obj', tmpl)

exports.index = (options) ->
  body = ck.render(require('./index.coffee'))
  tpls = require('./templates.coffee')

  js = '$__templates = {\n'
  for key,val of tpls
    # console.log ck.render(val)
    #console.log template(ck.render(val)).toString()
    tpl = template(ck.render(val)).toString().replace(/^function anonymous/, 'function')
    #console.log tpl
    js += "'#{key}': #{tpl},\n"
  js += '};'

  ast = jsp.parse(js)
  ast = pro.ast_mangle(ast)
  ast = pro.ast_squeeze(ast)
  js = pro.gen_code(ast)
  
  ck.render require('./layout.coffee'),
    body: body
    templates: js
    
exports.index()