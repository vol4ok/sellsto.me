{resolve} = require 'path'
ROOT = resolve(__dirname,'../')

module.exports = exports = 
  'include-dirs': ["#{ROOT}/src/scripts"]
  'output-dir': "#{ROOT}/app"
  'targets': ['app']
  'prerequired': ['jquery','core'] # this modeles will be included in all compiled files
  'style-dir': "#{ROOT}/src/styles"
  'targets-style': ['app']
  'view-dir': "#{ROOT}/src/views"
  