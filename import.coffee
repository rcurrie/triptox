csv = require 'ya-csv'
fs = require "fs"

mongo = require "mongodb"
db = new mongo.Db "triptox", new mongo.Server("localhost", mongo.Connection.DEFAULT_PORT, {}, {native_parser: false})

toTitleCase = (str) ->
  str.replace /\w\S*/g, (txt) ->
    txt.charAt(0).toUpperCase()+txt.substr(1).toLowerCase()

# Erase the existing database, ingest the facilities csv and create documents for each
db.open (err, db) ->
  db.dropDatabase (err, result) ->
    db.collection "facilities", (err, collection) ->

      collection.ensureIndex { loc : "2d" }, (err, indexName) ->
        console.log "Created location index #{indexName}"
        collection.indexInformation (err, doc) ->
          console.log "indexInformation: "
          console.log doc                

      collection.remove {}, (err, result) ->
        console.log "Deleted all existing facilities"
        fs.readdir "data",  (err, files) ->
          for file in files
            if file is ".DS_Store"
              continue
            do (file) ->
              console.log "Importing #{file}"
              reader = csv.createCsvFileReader "data/#{file}", { columnsFromHeader: true }
              reader.addListener 'data', (row) ->
                # console.log row["Facility Name"]
                collection.insert
                  name: toTitleCase(row["Facility Name"])
                  address: row["Facility Address"]
                  loc: [parseFloat(row["Latitude"]), parseFloat(row["Longitude"])]
                  sic_code: row["SIC Code"]
                  sic_description : row["SIC Description"]
                  naics_code: row["NAICS Code"]
                  naics_description: row["NAICS Description"]
                  pollutant: row["Pollutant"]
                  tons: parseFloat(row["Emissions in Tons"])
                  year: parseInt(row["Year"])
              reader.addListener "end", ->
                collection.count (err, count) ->
                  console.log "Added #{count} facilities"