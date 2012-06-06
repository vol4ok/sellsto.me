require('coffee-script');

global.$ = require('core.js');
$.ext(require('fs'));
$.ext(require('path'));
$.ext(require('util'));

require('./app/app');