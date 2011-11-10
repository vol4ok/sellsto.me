fs = require 'fs'
{join, dirname, basename} = require 'path'
_ = require 'underscore'
async = require 'async'
cfg = require './config'
require 'colors'
CoffeeScript = require './coffee-script/lib/coffee-script'
{compile} = CoffeeScript
{inspect} = require 'util'
stylus = require 'stylus'
less = require 'less'
jsp = require("uglify-js").parser
pro = require("uglify-js").uglify

REQUIRE_REGEX = /#\s*require\s+([A-Za-z_$-][A-Za-z0-9_$-.\/]*)/g
SCRIPT_FILES  = ['js', 'coffee']
STYLE_FILES   = ['css', 'styl', 'less']

indexIncludeDirectories = (includeDirs, types, prefix = '') ->
  index = {}
  includeDirs = [includeDirs] unless _.isArray(includeDirs)
  for dir in includeDirs
    for file in fs.readdirSync(dir)
      fullPath = join(dir,file)
      rx = new RegExp("^(.+)\\.(#{types.join('|')})$",'i')
      if rx.test(file)
        t = rx.exec(file)
        name = join(prefix,t[1])
        index[name] = 
          name: name
          type: t[2]
          path: fullPath
      else if fs.statSync(fullPath).isDirectory() and not /^__/.test(file)
        name = join(prefix,file)
        index[name] = 
          name: name
          type: 'dir'
          path: fullPath
        index extends indexIncludeDirectories(fullPath, types, name)
  return index
  
parseRequireDirective = (content) ->
  result = []
  content = '\n' + content
  result.push(match[1]) while (match = REQUIRE_REGEX.exec(content)) isnt null
  return result

findDependencies = (targets, index, opts = {}) ->
  result = []
  targets = [targets] unless _.isArray(targets)
  for target in targets
    if index[target]?
      d = _.clone(index[target])
      d.data = fs.readFileSync(d.path, 'utf8')
      r = parseRequireDirective(d.data)
      d.deps = findDependencies(r, index)
      d.opts = opts
      result.push(d)
      #result = result.concat(t)
    else 
      console.log "Warning: #{target} not found".yellow
  #result = _.uniq(result)
  return result #result.reverse()
  
compileTree = (tree) ->
  for d in tree
    compileTree(d.deps) if d.deps? and d.deps.length > 0
    if d.type is 'coffee'
      d.data = compile(d.data, d.opts)
  return tree

mergeTree = (tree) ->
  context = {}
  _mergeTreeRec = (tree) ->
    code = ''
    for d in tree
      unless context[d.name]?
        code += _mergeTreeRec(d.deps) if d.deps? and d.deps.length > 0
        code += "\n#{d.data}"
        context[d.name] = yes
    return code
  return _mergeTreeRec(tree)


mergeTreeCoffee = (tree) ->
  context = {}
  _mergeTreeRec = (tree) ->
    code = ''
    for d in tree
      unless context[d.name]?
        code += _mergeTreeRec(d.deps) if d.deps? and d.deps.length > 0
        code += "\n\n\n#{d.data}" if d.type is 'coffee'
        context[d.name] = yes
    return code
  return _mergeTreeRec(tree)
  
mergeTreeJs = (tree) ->
  context = {}
  _mergeTreeRec = (tree) ->
    code = ''
    for d in tree
      unless context[d.name]?
        code += _mergeTreeRec(d.deps) if d.deps? and d.deps.length > 0
        code += "\n\n\n#{d.data}" if d.type is 'js'
        context[d.name] = yes
    return code
  return _mergeTreeRec(tree)
  
mergeTreeEx = (tree, type) ->
  context = {}
  _mergeTreeRec = (tree) ->
    code = ''
    for d in tree
      unless context[d.name]?
        code += _mergeTreeRec(d.deps) if d.deps? and d.deps.length > 0
        code += "\n#{d.data}" if d.type is type
        context[d.name] = yes
    return code
  return _mergeTreeRec(tree)
  
removeDirectives = (content) ->
	content = content.replace(REQUIRE_REGEX, '')

cancatFiles = (files) ->
  result = ''
  for file in files
    content = fs.readFileSync(file, 'utf8')
    result += "\n" + content
  return result
  
build_prerequired = (index) ->
  code = {}
  for t in cfg['prerequired']
    unless (d = index[t])?
      console.log "ERROR: build prerequired #{t} failed".red
      continue
    code[d.type] = fs.readFileSync(d.path, 'utf-8')
  return code
  
######

exports.build_script = (options) ->
  options.env or= 'development'
  index = indexIncludeDirectories(cfg['include-dirs'], SCRIPT_FILES)
  prereq = build_prerequired(index)
  for target in cfg['targets']
    tree = findDependencies(target, index)
    coffeeCode = prereq['coffee']
    coffeeCode += '\n' + mergeTreeCoffee(tree)
    code = prereq['js'] + '\n' + mergeTreeJs(tree)
    code += '\n' + compile(coffeeCode, bare: no)
    if options.env is 'production'
      try
        ast = jsp.parse(code)
        ast = pro.ast_mangle(ast)
        ast = pro.ast_squeeze(ast)
        code = pro.gen_code(ast) 
      catch error
        console.log error
    fs.writeFileSync(join(cfg['output-dir'],"#{target}.js"), code, 'utf-8')
  return
  
build_stylus = (str, options, callback) ->
  stylus(str)
    .include(cfg['style-dir'])
    .set('filename', options.output)
    .set('compress', options.compress)
    .render callback
      
build_less = (str, options, callback) ->
  parser = new less.Parser
    paths: [cfg['style-dir']]
    filename: options.output
  parser.parse str, (err, tree) ->
    if err
      console.error err 
      callback(err)
    css = tree.toCSS(compress: options.compress)
    callback(err,css)

exports.build_style = (options) ->
  options.env or= 'production'
  index = indexIncludeDirectories(cfg['style-dir'], STYLE_FILES)
  
  for s in cfg['targets-style']
    input  = join(cfg['style-dir'], "#{s}.styl")
    output = join(cfg['output-dir'], "#{s}.css")
    # str = fs.readFileSync(input, 'utf-8')
    style_opt = 
      compress: if options.env is 'production' then yes else no
      output: output
    tree = findDependencies(s, index, style_opt)
    styl = mergeTreeEx(tree,'styl')
    _less = mergeTreeEx(tree,'less')
    css = mergeTreeEx(tree,'css')
    async.parallel
      styl: (callback) -> build_stylus styl, style_opt, callback
      less: (callback) -> build_less _less, style_opt, callback
    , (err, results) ->
      css += '\n' + results['less']
      css += '\n' + results['styl']
      fs.writeFileSync(output, css, 'utf-8')
  return
  
exports.build_view = (options) ->
  views = require('../src/views/build.coffee')
  fs.writeFileSync(join(cfg['output-dir'], "index.html"), views.index(), 'utf-8')