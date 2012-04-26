{Db,Server} = require('mongodb')
config = require('../config/app')

client = new Db(config.db.name, new Server(config.db.host, config.db.port, {}))
client.open (err, pClient) ->
  if (err == null)
    init.onModuleLoad("db")
  else
    throw err

module.exports = client