_ = require('underscore')._
mongoose = require "mongoose"
sp = require "./simplifyPath"

connect = require 'connect'

# Create our server and wire up middleware
server = connect.createServer()
server.use connect.static(__dirname + '/client')
server.use connect.compiler({src: __dirname + '/client', enable: ['coffeescript']})
server.use connect.errorHandler dumpExceptions: true, showStack: true

# Open the mongodb database
FacilitySchema = require __dirname + "/facility"
config = require __dirname + "/config"
db = mongoose.connect config.url
FacilityModel = mongoose.model "facility"

# REMIND: Move into import
FacilityModel.collection.ensureIndex [[ "loc", "2d"  ]], () -> {}
FacilityModel.collection.indexInformation (error, doc) ->
  console.log doc

FacilityModel.collection.count (err, count) ->
  console.log "#{count} facilities in the database"

# Create a router to handle requests
server.use connect.router (app) ->
  app.get "/status", (req, res) ->
    res.end("Up and running dude")

  app.post "/routes2facilities", (request, response) ->
    body = ""
    request.on "data", (data) ->
      body += data
    request.on "end", ->
      routes = JSON.parse body
      console.log "Found #{routes.length} routes"
      facilityLists = []
      for route in routes
        do (route) ->
          console.log "Looking for facilities near a route"
          # First simplify the route via line straightening to 5 miles tollerance
          simplifiedRoute = sp.GDouglasPeucker(route.overview_path, 1 * 1609.344)
          console.log "Simplified route from #{route.overview_path.length} to #{simplifiedRoute.length} points"
          pointsProcessed = simplifiedRoute.length
          facilityList = []
          for point in simplifiedRoute
            do (point) ->
              radius = 2.5 / 69 # 69 miles per degree roughly
              query = {"loc" : {"\$within" : {"\$center" : [[point.Pa, point.Qa], radius]}}}
              limit = {limit: 50, sort: [["_id", -1]] }
              FacilityModel.collection.find query, limit, (error, cursor) ->
                cursor.toArray (error, results) ->
                  console.log "Found #{results.length} facilities within #{radius} of #{point.Pa},#{point.Qa}\n"
                  for facility in results
                    facilityList.push(facility) unless _.detect(facilityList, (f) -> facility._id.equals(f._id))
                  pointsProcessed--
                  if pointsProcessed is 0
                    console.log "Found a total of #{facilityList.length} uniq facilities"
                    if facilityLists.push(facilityList) is routes.length
                      response.writeHead 200, {"Content-Type": "application/json"}
                      response.write JSON.stringify(facilityLists)
                      response.end()

# Startup the server
server.listen 3000
console.log "Server up and listening on port 3000"