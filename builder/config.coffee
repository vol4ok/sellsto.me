{resolve} = require 'path'
ROOT = resolve(__dirname,'../')
  
module.exports = exports = 
  script: 
    includes: ["#{ROOT}/src/scripts"]
    output: "#{ROOT}/app"
    resident: ['core_utils','vendor/jquery','core'] # this modeles will be included in all compiled files
    targets: ['app']
  style:
    includes: ["#{ROOT}/src/styles"]
    targets: ['app']
    output: "#{ROOT}/app"
  view:
    builder: "#{ROOT}/src/views/build.coffee"
    output: "#{ROOT}/app"
    targets: ['index']