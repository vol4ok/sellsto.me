mongoose = require('../db')
{Schema} = mongoose
{ObjectId} = Schema

UserSchema = new Schema
  name: String
  email: String
  password: String
  sessionId: String

User = mongoose.model('User', UserSchema)

exports.User = User