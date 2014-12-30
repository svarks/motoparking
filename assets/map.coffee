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

    renderMarkers = (meters) ->
      @renderMarker(meter) for meter in meters

    params =
      center: @gMap.center.toUrlValue()
      bounds: @gMap.getBounds().toUrlValue()

    $.getJSON('/search', params, renderMarkers.bind(this))

  renderMarker: (meter) ->
    marker = new google.maps.Marker(
      position: new google.maps.LatLng(meter.lat, meter.lng)
      map: @gMap
      title: JSON.stringify(meter.details, null, ' ')
    )

    @markers.push(marker)

    infowindow = new google.maps.InfoWindow(
      content: """
        <pre>
          #{JSON.stringify(meter.details, null, ' ')}
        </pre>
      """
    )
    google.maps.event.addListener marker, 'click', ->
      infowindow.open(@gMap, marker)

module.exports = Map
