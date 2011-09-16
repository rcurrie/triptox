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
      console.log "Server received #{routes.length} routes to process"
      facilityLists = routes.map (i) -> null # initialize so we know when we have processed all of them
      for curRoute in [0..routes.length-1]
        console.log "Processing route number #{curRoute}"
        do (curRoute) ->
          route = routes[curRoute]
          console.log "Looking for facilities near route #{curRoute}"
          # First simplify the route via line straightening to n miles tollerance
          simplifiedRoute = sp.GDouglasPeucker(route, 0.5 * 1609.344)
          console.log "Simplified route from #{route.length} to #{simplifiedRoute.length} points"
          pointsProcessed = 0
          console.log simplifiedRoute
          facilityList = []
          for point in simplifiedRoute
            do (point, facilityList, facilityLists) ->
              radius = 2.5 / 69 # 69 miles per degree roughly
              query = {"loc" : {"\$within" : {"\$center" : [[point[0], point[1]], radius]}}}
              # console.log "Looking around #{point[0]},#{point[1]}"
              limit = {limit: 50, sort: [["_id", -1]] }
              server.collection.find query, limit, (error, cursor) ->
                cursor.toArray (error, results) ->
                  if error
                    console.log "Problems querying for facilities around #{point[0]},#{point[1]}: #{error}"
                  else if results is null
                    console.log "Could not find any facilities around around #{point[0]},#{point[1]}"
                  else
                    console.log "Found #{results.length} facilities within #{radius} of #{point[0]},#{point[1]}\n"
                    for facility in results
                      facilityList.push(facility) unless _.detect(facilityList, (f) -> facility._id.equals(f._id))
                    pointsProcessed++
                    if pointsProcessed is simplifiedRoute.length
                      console.log "Found a total of #{facilityList.length} uniq facilities for route #{curRoute}"
                      facilityLists[curRoute] = facilityList
                      if _.every(facilityLists, (f) -> f)
                        console.log "Finished processing all routes"
                        response.writeHead 200, {"Content-Type": "application/json"}
                        response.write JSON.stringify(facilityLists)
                        response.end()

# Open the database and then start the server
db = new mongo.Db "triptox", new mongo.Server("localhost", mongo.Connection.DEFAULT_PORT, {}, {native_parser: false})
db.open (err, db) ->
  db.collection "facilities", (err, collection) ->
    server.db = db
    server.collection = collection
    server.listen 3000
    console.log "Server up and listening on port 3000"