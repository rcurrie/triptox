(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(function() {
    var FromToPage, MapPage, fromToPage, mapPage;
    MapPage = (function() {
      __extends(MapPage, Backbone.View);
      function MapPage() {
        MapPage.__super__.constructor.apply(this, arguments);
      }
      MapPage.prototype.gmap = null;
      MapPage.prototype.markers = [];
      MapPage.prototype.events = {
        "click a.route-selector": "handleSelectRoute"
      };
      MapPage.prototype.createMap = function() {
        if (this.gmap === null) {
          if (typeof console !== "undefined" && console !== null) {
            console.log("Creating map");
          }
          $("#map-canvas").height($("#map-page").height() - $("#map-header").height());
          this.gmap = new google.maps.Map(document.getElementById("map-canvas"), {
            zoom: 8,
            mapTypeId: google.maps.MapTypeId.ROADMAP
          });
          this.directionsService = new google.maps.DirectionsService();
          this.directionsDisplay = new google.maps.DirectionsRenderer();
          this.directionsDisplay.setMap(this.gmap);
          return this.infowindow = new google.maps.InfoWindow({
            size: new google.maps.Size(50, 50)
          });
        }
      };
      MapPage.prototype.getRoutesAndFacilities = function(from, to) {
        var params;
        params = {
          "origin": from,
          "destination": to,
          "travelMode": google.maps.DirectionsTravelMode.DRIVING,
          provideRouteAlternatives: true
        };
        return this.directionsService.route(params, __bind(function(response, status) {
          var routes;
          if (status === google.maps.DirectionsStatus.OK) {
            if (typeof console !== "undefined" && console !== null) {
              console.log("Found " + response.routes.length + " routes");
            }
            routes = response.routes.map(function(i) {
              return i.overview_path.map(function(j) {
                return [j.lat(), j.lng()];
              });
            });
            this.directionsDisplay.setDirections(response);
            if (typeof console !== "undefined" && console !== null) {
              console.log("Sending routes to server");
            }
            return $.ajax('/routes2facilities', {
              type: 'POST',
              data: JSON.stringify(routes),
              dataType: 'html',
              error: __bind(function(jqXHR, textStatus, errorThrown) {
                return typeof console !== "undefined" && console !== null ? console.log("Error sending route to server " + textStatus) : void 0;
              }, this),
              success: __bind(function(result) {
                this.facilityLists = JSON.parse(result);
                if (typeof console !== "undefined" && console !== null) {
                  console.log("Received " + this.facilityLists.length + " lists of facilities");
                }
                $.mobile.pageLoading(true);
                $(".route-selector").each(__bind(function(index, element) {
                  $(element).removeClass("ui-btn-active");
                  if (this.facilityLists[index] != null) {
                    $(".ui-btn-text", element).html("" + this.facilityLists[index].length);
                    return $(element).show();
                  } else {
                    return $(element).hide();
                  }
                }, this));
                $(".route-selector").first().addClass('ui-btn-active');
                $('#map-page').page();
                return this.displayRoute(0);
              }, this)
            });
          } else {
            return typeof console !== "undefined" && console !== null ? console.log("Problems routing: " + status) : void 0;
          }
        }, this));
      };
      MapPage.prototype.displayRoute = function(routeNum) {
        var facility, marker, _i, _j, _len, _len2, _ref, _ref2, _results;
        this.directionsDisplay.setRouteIndex(routeNum);
        if (typeof console !== "undefined" && console !== null) {
          console.log("Found " + this.facilityLists[routeNum].length + " facilities associated with route " + routeNum);
        }
        _ref = this.markers;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          marker = _ref[_i];
          marker.setMap(null);
        }
        _ref2 = this.facilityLists[routeNum];
        _results = [];
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          facility = _ref2[_j];
          _results.push(__bind(function(facility) {
            marker = new google.maps.Marker({
              position: new google.maps.LatLng(facility.loc[0], facility.loc[1]),
              map: this.gmap,
              title: facility.name,
              facility: facility
            });
            this.markers.push(marker);
            return (function(marker, facility, gmap, infowindow) {
              this.gmap = gmap;
              this.infowindow = infowindow;
              google.maps.event.addListener(marker, "click", __bind(function(e) {
                var content;
                content = "<b>" + facility.name + "</b><br/>" + facility.naics_description + "<br/>" + facility.pollutant + "<br/>";
                infowindow.setContent(content);
                return infowindow.open(this.gmap, marker);
              }, this));
              return google.maps.event.addListener(marker, "mousedown", __bind(function(e) {
                var content;
                content = "<b>" + facility.name + "</b><br/>" + facility.naics_description + "<br/>" + facility.pollutant + "<br/>";
                infowindow.setContent(content);
                return infowindow.open(this.gmap, marker);
              }, this));
            })(marker, facility, this.gmap, this.infowindow);
          }, this)(facility));
        }
        return _results;
      };
      MapPage.prototype.handleSelectRoute = function(e) {
        return this.displayRoute($(e.currentTarget).data("route-num"));
      };
      return MapPage;
    })();
    mapPage = new MapPage({
      el: $("#map-page")
    });
    FromToPage = (function() {
      __extends(FromToPage, Backbone.View);
      function FromToPage() {
        FromToPage.__super__.constructor.apply(this, arguments);
      }
      FromToPage.prototype.events = {
        "click a#get-directions-button": "createMap"
      };
      FromToPage.prototype.createMap = function(e) {
        $.mobile.changePage("#map-page");
        mapPage.createMap();
        $.mobile.loadingMessage = 'Routing...';
        $.mobile.pageLoading(false);
        return mapPage.getRoutesAndFacilities($("#from").val(), $("#to").val());
      };
      return FromToPage;
    })();
    return fromToPage = new FromToPage({
      el: $('#from-to-page')
    });
  });
}).call(this);
