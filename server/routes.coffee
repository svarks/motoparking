express    = require 'express'
browserify = require 'browserify-middleware'
meters     = require './meters'

router = express.Router()

router.get '/', (req, res) ->
  res.render('index')

router.get '/search', (req, res) ->
  [center, bounds] = [req.query.center, req.query.bounds].map (values) ->
    values.split(',').map(parseFloat)

  sendData = (data) -> res.send(data)

  meters.search(center, bounds, sendData)

router.get '/app.js', browserify('./assets/app.coffee',
  transform: ['coffeeify']
  extensions: ['.coffee']
)

module.exports = router
