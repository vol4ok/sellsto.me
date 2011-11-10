_ = require 'underscore'
ck = require 'coffeekup'
fs = require 'fs'
{join} = require 'path'
jsp = require("uglify-js").parser
pro = require("uglify-js").uglify

exports.index = (options) ->
  body = ck.render(require('./index.coffee'))
  tpls = require('./templates.coffee')

  js = '$__templates = {\n'
  for key,val of tpls
    tpl = _.template(ck.render(val)).toString().replace(/^function anonymous/, 'function')
    js += "'#{key}': #{tpl},\n"
  js += '};'

  ast = jsp.parse(js)
  ast = pro.ast_mangle(ast)
  ast = pro.ast_squeeze(ast)
  js = pro.gen_code(ast)
  
  ck.render require('./layout.coffee'),
    body: body
    templates: js