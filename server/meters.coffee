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
    msId        : data['METER_TYPE'] == 'MS' && data['MS_ID'] || null
    streetName  : data['STREETNAME']
    lat         : parseFloat(data['LAT'])
    lng         : parseFloat(data['LONG'])
    details     : data
  }

buildMeters = (cb) ->
  readData (results) ->
    cb(results.map(buildMeter))

buildLocations = (cb) ->
  buildMeters (meters) ->
    locations = {}

    for meter in meters
      key = meter.msId || meter.postId
      location = locations[key] ?= { meters: [] }
      location.meters.push(meter)

    for id, location of locations
      for attr in ['lat', 'lng']
        sum = _.reduce(location.meters, ((sum, meter) -> sum + meter[attr]), 0)
        location[attr] = sum / location.meters.length

    cb(_.values(locations))

cachedLocations = null

getLocations = (cb) ->
  if cachedLocations
    cb(cachedLocations)
  else
    buildLocations (locations) ->
      cachedLocations = locations
      cb(locations)

meters =
  search: (center, bounds, cb) ->
    [centerLat, centerLng] = center
    [swLat, swLng, neLat, neLng] = bounds

    isInBounds = (meter) ->
      neLat > meter.lat > swLat &&
      neLng > meter.lng > swLng

    getLocations (locations) ->
      results = []

      for location in locations
        if isInBounds(location)
          location = _.clone(location)
          location.distance = distance([centerLat, centerLng], [location.lat, location.lng], true)

          results.push(location)

      results = _.sortBy(results, (location) -> location.distance)

      cb(results)

module.exports = meters
