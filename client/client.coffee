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

    gmap = null
    directionsService = null
    directionsDisplay = null
    
    createMap: (e) ->
      # $('#map-canvas').gmap({'callback': @mapCreated()})
      $.mobile.changePage("#map-page")
      $.mobile.loadingMessage = 'Getting routes...'
      $.mobile.pageLoading false

      if gmap
        console.log "map already exists"
      else
        latlng = new google.maps.LatLng(59.3426606750, 18.0736160278);
        gmap = new google.maps.Map(document.getElementById("map-canvas"), {zoom: 8, center: latlng, mapTypeId: google.maps.MapTypeId.ROADMAP})
        directionsService = new google.maps.DirectionsService()
        directionsDisplay = new google.maps.DirectionsRenderer()
        directionsDisplay.setMap(gmap)


    
      params = { "origin": $("#from").val(), "destination": $("#to").val(), "travelMode": google.maps.DirectionsTravelMode.DRIVING, provideRouteAlternatives: true }
      console.log params
      directionsService.route params, (response, status) ->
        if status is google.maps.DirectionsStatus.OK
          directionsDisplay.setDirections(response)
          directionsDisplay.setRouteIndex(1)

          console.log "Found #{response.routes.length} routes"
          for loc in response.routes[0].overview_path
            console.log loc

          $.mobile.loadingMessage = 'Analyzing routes...'

          console.log "Sending route to server for analysis"
          $.ajax '/routes',
            type: 'POST'
            data: JSON.stringify response.routes
            dataType: 'html'
            error: (jqXHR, textStatus, errorThrown) ->
              console.log "Error sending route to server #{textStatus}"
            success: (data) ->
              console.log "Got data from server based on route"
              console.log data
              $.mobile.pageLoading true

        else
          console.log "Problems getting directions: #{status}"


  
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