# Open the database
mongoose = require "mongoose"
FacilitySchema = require __dirname + "/facility"
config = require __dirname + "/config"
db = mongoose.connect config.url
FacilityModel = mongoose.model "facility"


# REMIND: Move into import
FacilityModel.collection.ensureIndex [[ "loc", "2d"  ]], () -> {}

# FacilityModel.collection.indexInformation (error, doc) ->
#   console.log doc

FacilityModel.collection.count (err, count) ->
  console.log "#{count} facilities in the database"



#Works!!
# center = [37.93767, -122.39617]
# distance = 1
# radius = distance / 112.63
# query = {"loc" : {"\$within" : {"\$center" : [center, radius]}}}
# limit = {limit: 100, sort: [["_id", -1]] }
# console.log "Querying: " + center[0].toString() + " : " + center[1].toString() + ", " + distance.toString()
# FacilityModel.collection.find query, limit, (error, cursor) ->
#   cursor.toArray (error, results) ->
#     render "Found #{results.length} near the center"


http = require 'http'
url = require 'url'
util = require 'util'
fs = require 'fs'
static = require 'node-static'

staticServer = new static.Server('../client')

httpServer = http.createServer (request, response) ->
  command = url.parse(request.url, true)
  switch command.pathname      
    when '/status'
      response.writeHead 200, {'Content-Type': 'text/html'}
      response.write 'Server up and running\n'
      response.end()

    when '/routes'
      console.log command.query
      body = '';
      request.on 'data', (data) ->
        body += data
      request.on 'end', ->
        routes = JSON.parse body
        console.log "Found #{routes.length} routes"

      response.writeHead 200, {'Content-Type': 'text/html'}
      response.write 'Got some routes\n'
      response.end()

    when '/articles'
      console.log 'Serving up articles'
      httpRequest = http.get { host: 'news.ycombinator.com', port: 80, path: '/rss'}, (httpResponse) ->
        httpResponse.on 'data', (chunk) ->
          response.write chunk, 'binary'
        httpResponse.on 'end', (chunk) ->
          response.end()
      httpRequest.end()

    when '/facilities'
      console.log command.query
      center = [parseFloat(command.query.lat), parseFloat(command.query.lon)]
      distance = parseFloat(command.query.dist)
      radius = distance / 112.63
      query = {"loc" : {"\$within" : {"\$center" : [center, radius]}}}
      limit = {limit: 100, sort: [["_id", -1]] }
      console.log "Querying: " + center[0].toString() + " : " + center[1].toString() + ", " + distance.toString()
      FacilityModel.collection.find query, limit, (error, cursor) ->
        cursor.toArray (error, results) ->
          console.log "Found #{results.length}\n"
          response.writeHead 200, {'Content-Type': 'text/html'}
          response.write JSON.stringify(results)
          response.end()
    
    else 
      request.addListener 'end', ->
        console.log("Servicing static request to " + request.url)
        staticServer.serve(request, response)

httpServer.listen(3000)
console.log 'Server listening on port 3000'

