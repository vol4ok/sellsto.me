module.exports = (app) ->
  {Schema} = app.db
  UserSchema = new Schema
    name: String
    email: String
    password: String
    sessionId: String
  exports.User = app.db.model('User', UserSchema)