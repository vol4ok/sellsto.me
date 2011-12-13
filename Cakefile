{build_script, build_style, build_view} = require './builder'
  
option '-e', '--env [ENVIRONMENT_NAME]', 'set the environment for `build:script`'

task 'build:script', 'Build script files', (options) ->
  build_script(options)
  
task 'build:style', 'Build style files', (options) ->
  build_style(options)
  
task 'build:view', 'Build html-views', (options) ->
  build_view(options)

task 'build', 'Build all project', (options) ->
  invoke 'build:script'
  invoke 'build:style'
  invoke 'build:view'

  
  