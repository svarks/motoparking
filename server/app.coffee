express     = require 'express'
logger      = require 'morgan'
path        = require 'path'
stylus      = require 'stylus'
compression = require 'compression'

port = Number(process.env.PORT || 5000)

app = express()

app.set 'views', path.join(__dirname, '/views')
app.set 'view engine', 'jade'

app.use logger('dev')
app.use stylus.middleware(src: path.join(__dirname, '../assets'))
app.use express.static(path.join(__dirname, '../assets'))
app.use compression()

app.use '/', require('./routes')

app.listen port, ->
  console.log "Listening on #{port}"
