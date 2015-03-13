require './ga'
Map = require './map'

getLocation = (cb) ->
  navigator.geolocation.getCurrentPosition (position) ->
    cb(position.coords)

$ ->
  map = null

  getLocation (coords) ->
    map = new Map($('.map-canvas')[0])
    map.render(coords)

  $('.refresh-button').on 'click', ->
    map.loadMeters() if map
