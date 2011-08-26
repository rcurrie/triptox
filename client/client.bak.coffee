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
  facilities.each (facility) ->
    console.log facility
    
  #==============================================================================
  # Views
  class FacilityDetailView extends Backbone.View
    template: _.template($('#facility-detail-view-template').html())
    render: =>
      $('#facility-title').text(@model.get('name'))
      $('#facility-original-button').attr('href', "http://yahoo.com")
      @el.html(@template({facility : @model}))

  facilityDetailView = new FacilityDetailView {el: $('#facility-detail-view')}
      
  class FacilityListView extends Backbone.View
    template: _.template($('#facility-list-view-template').html())
    events : {
      "click" : "handleShowFacilityDetail"
    }
    constructor: ->
      super
      _.bindAll(this, 'render');
      @collection.bind 'all', @render
      
    handleShowFacilityDetail: (e) ->
      facilityDetailView.model = this.collection.getByCid(e.target.getAttribute("data-cid"))
      facilityDetailView.render()
      $.mobile.changePage("#facility-detail-page")
      
    render: =>
      @el.html(@template({facilities : @collection}))
      @el.find('ul[data-role]').listview()
      
  facilityListView = new FacilityListView {collection: facilities, el: $ "#facility-list-view"}
  facilityListView.render()

  #==============================================================================
  # Controllers
  $('#refresh-button').click ->
    $.mobile.loadingMessage = 'Refreshing facilities...'
    $.mobile.pageLoading false
    facilities.getFacilities -> $.mobile.pageLoading true

  $('#clear-button').click ->
    # .each doesn't work, only deletes a handfull at a time, why?
    # facilities.each (facility) -> facility.destroy()
    facilities.first().destroy() while facilities.length

  $('#facility-detail-view').bind 'swipeleft', ->
    i = facilities.indexOf(facilityDetailView.model)
    if i < facilities.length-1
      facilityDetailView.model = facilities.at(i+1)
      facilityDetailView.render()
  
  $('#facility-detail-view').bind 'swiperight', ->
    i = facilities.indexOf(facilityDetailView.model)
    if i > 0
      facilityDetailView.model = facilities.at(i-1)
      facilityDetailView.render()

  $('#map_canvas').gmap('refresh')

   $(function() {
                // Also works with: var yourStartLatLng = '59.3426606750, 18.0736160278';
                var yourStartLatLng = new google.maps.LatLng(59.3426606750, 18.0736160278);
                $('#map_canvas').gmap({'center': yourStartLatLng});
        });
