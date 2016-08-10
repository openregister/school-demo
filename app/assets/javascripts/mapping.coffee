
$(document).ready( ->
  root = exports ? this
  mapDiv = $("#map")
  if mapDiv?
    lat = mapDiv.data("lat")
    lon = mapDiv.data("lon")
    host = mapDiv.data('host')
    key = mapDiv.data('key')
    attribution = mapDiv.data("attribution")

    zoom = 15

    map = L.map("map",
      center: [
        lat
        lon
      ]
      zoom: zoom
    )
    map.scrollWheelZoom.disable()

    L.control.scale(
      position: "topright"
      imperial: false
    ).addTo map

    map.attributionControl.setPrefix ""

    if(L.Browser.retina)
      tp = "lr"
    else
      tp = "ls"

    # L.tileLayer(host+'/'+tp+"/{z}/{x}/{y}?apikey=#{key}",
    L.tileLayer(host+"/{z}/{x}/{y}.png",
      attribution: $('<div />').html(attribution).text(),
      maxZoom: 18
    ).addTo map

    schools = $('.school')
    schools.each (i) ->
      school = schools.eq(i)
      lat = school.data('lat')
      if lat?
        lon = school.data('lon')
        options = { stroke: false, color: '#3f3', fillOpacity: 0.1 }
        marker = L.marker([lat,lon], options)
        # circle.setRadius(20)
        marker.addTo(map)
        marker.bindPopup("<p>" + school.parent().html() + "</p>")

)
