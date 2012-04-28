mongoose = require('mongoose')
config = require('../config/app')

mongoose.connect("mongodb://#{config.db.host}/#{config.db.name}");

module.exports = mongoose