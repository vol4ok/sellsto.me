fs = require 'fs'
{join, dirname, basename} = require 'path'
_ = require 'underscore'
async = require 'async'
config = require './config'
require 'colors'
CoffeeScript = require './coffee-script/lib/coffee-script' #./coffee-script/lib/
less = require 'less'
jsp = require("uglify-js").parser
pro = require("uglify-js").uglify

REQUIRE_REGEX = /#\s*require\s+([A-Za-z_$-][A-Za-z0-9_$-.\/]*)/g
SCRIPT_FILES  = ['js', 'coffee']
STYLE_FILES   = ['css', 'less']

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
      d.deps = findDependencies(r, index, opts)
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
      d.data = CoffeeScript.compile(d.data, d.opts)
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
  
buildList = (list, index, opts) ->
  code = ''
  for t in list
    unless (d = index[t])?
      console.log "ERROR: build prerequired #{t} failed".red
      continue
    if d.type == 'coffee'
      console.log d.path
      code += CoffeeScript.compile(fs.readFileSync(d.path, 'utf-8'), opts)
    else if d.type == 'js'
      code += fs.readFileSync(d.path, 'utf-8')
    else 
      console.log "ERROR: unknown filetype \"#{d.type}\"".red
  return code
  
buildLess = (str, options, callback) ->
  parser = new less.Parser
    paths: options.includes
    filename: options.output
  parser.parse str, (err, tree) ->
    if err
      console.error err 
      callback(err)
    css = tree.toCSS(compress: options.compress)
    callback(err,css)
  
######
  
exports.build_script = (options) ->
  options.env or= 'development'
  cfg = config.script
  index = indexIncludeDirectories(cfg['includes'], SCRIPT_FILES)
  resident = buildList(cfg['resident'], index, {bare: true, utilities: no})
  for target in cfg['targets']
    tree = findDependencies(target, index, {bare: true, utilities: no})
    tree = compileTree(tree)
    code = resident + mergeTree(tree)
    if options.env is 'production'
      try
        ast = jsp.parse(code)
        ast = pro.ast_mangle(ast)
        ast = pro.ast_squeeze(ast)
        code = pro.gen_code(ast) 
      catch error
        console.log error
    fs.writeFileSync(join(cfg['output'],"#{target}.js"), code, 'utf-8')

exports.build_style = (options) ->
  options.env or= 'production'
  cfg = config.style
  index = indexIncludeDirectories(cfg['includes'], STYLE_FILES)
  for s in cfg['targets']
    output = join(cfg['output'], "#{s}.css")
    style_opt = 
      includes: cfg['includes']
      compress: if options.env is 'production' then yes else no
      output: output
    tree = findDependencies(s, index, style_opt)
    _less = mergeTreeEx(tree,'less')
    css = mergeTreeEx(tree,'css')
    buildLess _less, style_opt, (err, result) ->
      css += '\n' + result
      fs.writeFileSync(output, css, 'utf-8')
  return
  
exports.build_view = (options) ->
  cfg = config.view
  builder = require(cfg['builder'])
  for target in cfg['targets']
    fs.writeFileSync(join(cfg['output'], "#{target}.html"), builder[target](), 'utf-8')