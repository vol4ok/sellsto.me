exports.PORT = 80
exports.SECURE_PORT = 443
exports.INTERFACE = '127.0.0.1'
BASE_DIR = exports.BASE_DIR = process.cwd()
exports.STATIC = "#{BASE_DIR}/public"
exports.db =
  name: "sells2me_api_dev"
  host: "127.0.0.1"
  port: 27017