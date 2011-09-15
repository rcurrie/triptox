_ = require('underscore')._
mongo = require "mongodb"
sp = require "./simplifyPath"
connect = require 'connect'


# NOTE: Order is important here, compiler must come first otherwise static will server
# the existing .js file before compiler can see that it needs to be updated
server = connect.createServer()
# server.use connect.logger()
server.use connect.compiler({src: __dirname + "/client", enable: ['coffeescript']})
server.use connect.static(__dirname + "/client")
server.use connect.errorHandler dumpExceptions: true, showStack: true

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
      routeNum = 0
      for route in routes
        routeNum++
        do (route, routeNum) ->
          console.log "Looking for facilities near a route"
          # First simplify the route via line straightening to 5 miles tollerance
          simplifiedRoute = sp.GDouglasPeucker(route, 1 * 1609.344)
          console.log "Simplified route from #{route.length} to #{simplifiedRoute.length} points"
          pointsProcessed = simplifiedRoute.length
          console.log simplifiedRoute
          facilityList = []
          for point in simplifiedRoute
            do (point) ->
              radius = 2.5 / 69 # 69 miles per degree roughly
              query = {"loc" : {"\$within" : {"\$center" : [[point[0], point[1]], radius]}}}
              console.log "Looking around #{point[0]},#{point[1]}"
              limit = {limit: 50, sort: [["_id", -1]] }
              server.collection.find query, limit, (error, cursor) ->
                cursor.toArray (error, results) ->
                  if error
                    console.log "Problems querying for facilities: #{error}"
                  else if results is null
                    console.log "Could not fine any facilities"
                  else
                    console.log "Found #{results.length} facilities within #{radius} of #{point[0]},#{point[1]}\n"
                    for facility in results
                      facilityList.push(facility) unless _.detect(facilityList, (f) -> facility._id.equals(f._id))
                    pointsProcessed--
                    if pointsProcessed is 0
                      console.log "Found a total of #{facilityList.length} uniq facilities"
                      facilityLists[routeNum-1] = facilityList
                      if routeNum is routes.length
                      # if facilityLists.push(facilityList) is routes.length
                        response.writeHead 200, {"Content-Type": "application/json"}
                        response.write JSON.stringify(facilityLists)
                        response.end()

                        for l in facilityLists
                          console.log l[0].name

# Open the database and then start the server
db = new mongo.Db "triptox", new mongo.Server("localhost", mongo.Connection.DEFAULT_PORT, {}, {native_parser: false})
db.open (err, db) ->
  db.collection "facilities", (err, collection) ->
    server.db = db
    server.collection = collection
    server.listen 3000
    console.log "Server up and listening on port 3000"