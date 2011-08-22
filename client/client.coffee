$ ->
  #==============================================================================
  # Models
  class FacilityModel extends Backbone.Model

  class FacilityCollection extends Backbone.Collection
    model: FacilityModel
    localStorage: new Store "facilities"

    # downloadFacility: (link, title) =>
    #   # JSONP so we can get around the cross domain restrictions for HTML5
    #   console.log 'GETing ' + title + ' ' + link
    #   $.getJSON "http://viewtext.org/api/text?url=" + link + "&callback=?", (data) ->
    #     console.log 'Got ' + link
    #     facilities.create {title: title, link: link, timeStamp: new Date(), content: data.content}

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
          data.each (facility) ->
            console.log facility._id
            # link = $(this).find('link').text()
            # title = $(this).find('title').text()
            # if not facilities.detect ((facility) -> facility.get("link") is link)
            #   console.log 'New facility: ' + title
            #   facilities.downloadFacility link, title
          callback()
      }  

  facilities = new FacilityCollection()
  facilities.fetch()
    
  #==============================================================================
  # Views
  class FacilityDetailView extends Backbone.View
    template: _.template($('#facility-detail-view-template').html())
    render: =>
      $('#facility-title').text(@model.get('name'))
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