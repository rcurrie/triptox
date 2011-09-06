# edit these
config =
  user: 'root',
  password: '',
  host: 'localhost',
  port: '27017',
  database: 'triptox'

# probably don't edit this
module.exports =
  url: 'mongodb://' + config.user + ':' + config.password + '@' + config.host + ':' + config.port + '/' + config.database