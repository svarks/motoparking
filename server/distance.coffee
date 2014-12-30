earthRadius =
  km: 6371
  mi: 3956

deg2rad = (deg) ->
  deg * Math.PI / 180

distance = (from, to, useMiles = false) ->
  [lat1, lon1] = from
  [lat2, lon2] = to

  dLat = deg2rad(lat2 - lat1)
  dLon = deg2rad(lon2 - lon1)

  a = Math.pow(Math.sin(dLat / 2), 2) +
      Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
      Math.pow(Math.sin(dLon / 2), 2)

  c = 2 * Math.asin(Math.sqrt(a))

  r = if useMiles then earthRadius.mi else earthRadius.km
  r * c

module.exports = distance
