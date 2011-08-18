# Open the database
mongoose = require 'mongoose'
FacilitySchema = require __dirname + '/facility'
config = require __dirname + '/config'
mongoose.connect config.url
FacilityModel = mongoose.model 'facility'

# Delete ALL existing entries
FacilityModel.find (error, facilities) ->
  console.log "Deleting #{facilities.length} existing facilities in the database"
  for facility in facilities
    facility.remove()

  # Read the csv file and create documents for each in mongodb
  csv = require 'ya-csv'
  reader = csv.createCsvFileReader '../data/ca.nox.100.csv'

  reader.addListener 'data', (row) ->
    facility = new FacilityModel
      name: row[0]
      address: row[1]
      loc: [parseFloat(row[2]), parseFloat(row[3])]
      sic_code: row[4]
      sic_description : row[5]
      naics_code: row[6]
      naics_description: row[7]
      pollutant: row[8]
      tons: parseFloat(row[9])
      year: parseInt(row[10])

    facility.save (err) ->
      console.log "Saved #{row}"










