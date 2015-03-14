class Map
  constructor: (el) ->
    @el = el
    @markers = []

  render: (coords) ->
    console.log "Current Location: #{coords.latitude}, #{coords.longitude}"

    mapOptions =
      center: { lat: coords.latitude, lng: coords.longitude }
      zoom: 15

    @gMap = new google.maps.Map(@el, mapOptions)
    window.map = @gMap

    google.maps.event.addListenerOnce(@gMap, 'idle', @loadMeters.bind(this))

  loadMeters: ->
    marker.setMap(null) for marker in @markers
    @markers = []

    renderMarkers = (locations) ->
      @renderMarker(location) for location in locations

    params =
      center: @gMap.center.toUrlValue()
      bounds: @gMap.getBounds().toUrlValue()

    $.getJSON('/search', params, renderMarkers.bind(this))

  renderMarker: (location) ->
    number = location.meters.length

    color =
      if number > 1
        'fe6'
      else
        'f66'

    marker = new google.maps.Marker(
      position: new google.maps.LatLng(location.lat, location.lng)
      map: @gMap
      icon: "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=#{number}|#{color}|333"
    )

    @markers.push(marker)

    infowindow = new google.maps.InfoWindow(
      content: """
        <pre>
          #{JSON.stringify(location.meters, null, ' ')}
        </pre>
      """
    )
    google.maps.event.addListener marker, 'click', ->
      infowindow.open(@gMap, marker)

module.exports = Map
