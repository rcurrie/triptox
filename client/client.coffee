$ ->
  #==============================================================================
  # Models
  class FacilityModel extends Backbone.Model

  class FacilityCollection extends Backbone.Collection
    model: FacilityModel
    localStorage: new Store "facilities"

    comparator: (facility) ->
      -1 * facility.get "tons"
    
    getFacilities: (callback) =>     
      console.log 'Getting facilities'
      $.ajax {
        # relative url unless running inside phonegap
        url: if device? then "http://longink.ampdat.com/facilities" else "/facilities?lat=37.93767&lon=-122.39617&dist=5"
        dataType: "json"
        error: (xhr, errMsg, err) ->
          console.log "Error getting facilities" + errMsg
        success: (data) =>
          console.log 'Received nearby facilities'
          console.log data
          for item in data
            if not facilities.detect ((facility) -> facility.get("_id") is item._id)
              console.log 'New facility: ' + item.name
              facilities.create item
          callback()
      }  

  facilities = new FacilityCollection
  facilities.fetch()
  # facilities.each (facility) ->
  #   console.log facility

  #==============================================================================
  # Views
  # class MapPage extends Backbone.View
  #   template: _.template($('#facility-list-view-template').html())
  #   events : {
  #     "click" : "handleShowFacilityDetail"
  #   }
  #   constructor: ->
  #     super
  #     _.bindAll(this, 'render');
  #     @collection.bind 'all', @render
      
  #   handleShowFacilityDetail: (e) ->
  #     facilityDetailView.model = this.collection.getByCid(e.target.getAttribute("data-cid"))
  #     facilityDetailView.render()
  #     $.mobile.changePage("#facility-detail-page")
      
  #   render: =>
  #     @el.html(@template({facilities : @collection}))
  #     @el.find('ul[data-role]').listview()
      
  # mapPage = new MapPage {el: $ "#map-page"}

  class FromToPage extends Backbone.View
    events : {
      "click a#get-directions-button" : "createMap"
    }

    createMap: (e) ->
      $('#map-canvas').gmap({'callback': @mapCreated()})

    mapCreated: =>
      $.mobile.changePage("#map-page")
      # Also works with: var yourStartLatLng = '59.3426606750, 18.0736160278';
      yourStartLatLng = new google.maps.LatLng(59.3426606750, 18.0736160278);
      $('#map-canvas').gmap({'center': yourStartLatLng});

      params = { "origin": $("#from").val(), "destination": $("#to").val(), "travelMode": google.maps.DirectionsTravelMode.DRIVING }
      console.log params
      $("#map-canvas").gmap "displayDirections", params, { "panel": document.getElementById("directions")}, (response, status) =>
        console.log "got directions response #{status}"


  
  fromToPage = new FromToPage {el: $('#from-to-page')}
      
  #==============================================================================
  # Controllers  
  # console.log "getting current position"
  # console.log $("#map-canvas")
  # $("#map-canvas").gmap "getCurrentPosition", (position, status) ->
  #   console.log "getCurrentPosition returned"
  #   if status is "OK"
  #     console.log "Position appears OK"
  #     latlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
  #     $("#map-canvas").gmap("get", "map").panTo(latlng)
  #     $("#map-canvas").gmap "search", { "location": latlng }, (results, status) ->
  #       if status is "OK"
  #         $("#from").val(results[0].formatted_address)
  #   else
  #     alert("Unable to get current position")

  # $("#map_canvas_1").gmap({"center": "59.3426606750, 18.0736160278"})
  # $("#submit").click ->
  #   console.log "got click!"
  #   $("#map_canvas_1").gmap "displayDirections", { "origin": $("#from").val(), "destination": $("#to").val(), "travelMode": google.maps.DirectionsTravelMode.DRIVING }, { "panel": document.getElementById("directions")}, (response, status) =>
  #     console.log "got directions response"
  #     if status is "OK"
  #       $("#results").show()
  #     else
  #       $("#results").hide()
  #   return false