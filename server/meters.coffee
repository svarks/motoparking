fs       = require 'fs'
parse    = require 'csv-parse'
_        = require 'lodash'
distance = require './distance'

readData = (cb) ->
  fs.readFile './data/MotorcycleMeters_20130412.csv', (err, data) ->
    parse data, { columns: true }, (err, results) ->
      cb(results)

buildMeter = (data) ->
  {
    postId      : data['POST_ID']
    streetName  : data['STREETNAME']
    lat         : parseFloat(data['LAT'])
    lng         : parseFloat(data['LONG'])
    details     : data
  }

loadMeters = (cb) ->
  readData (results) ->
    cb(results.map(buildMeter))

cachedMeters = null

getMeters = (cb) ->
  if cachedMeters
    cb(cachedMeters)
  else
    loadMeters (meters) ->
      cachedMeters = meters
      cb(meters)

meters =
  search: (center, bounds, cb) ->
    [centerLat, centerLng] = center
    [swLat, swLng, neLat, neLng] = bounds

    isInBounds = (meter) ->
      neLat > meter.lat > swLat &&
      neLng > meter.lng > swLng

    getMeters (meters) ->
      results = []

      for meter in meters
        if isInBounds(meter)
          meter = _.clone(meter)
          meter.distance = distance([centerLat, centerLng], [meter.lat, meter.lng], true)

          results.push(meter)

      results = _.sortBy(results, (meter) -> meter.distance)

      cb(results)

module.exports = meters
