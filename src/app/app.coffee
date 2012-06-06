app = require './config/app'

# initialize models
['user'].forEach (mod) -> require "./models/#{mod}"

# initialize controllers
['main'].forEach (ctr) -> require "./controllers/#{ctr}"

app.db.connect("mongodb://#{app.cfg.db.host}/#{app.cfg.db.name}")
app.listen(app.cfg.port, app.cfg.interface)