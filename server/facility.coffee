mongoose = require 'mongoose'

# "Facility Name","Facility Address","Latitude","Longitude","SIC Code","SIC Description","NAICS Code","NAICS Description","Pollutant","Emissions in Tons","Year"

FacilitySchema = new mongoose.Schema
  name: String
  address: String
  loc: [Number] # NOTE: Use array as hash can have ordering problems in js
  sic_code: String
  sic_description : String
  naics_code: String
  naics_description: String
  pollutant: String
  tons: Number
  year: Number

mongoose.model 'facility', FacilitySchema