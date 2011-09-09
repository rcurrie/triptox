mongoose = require 'mongoose'

# "Facility Name","Facility Address","Latitude","Longitude","SIC Code","SIC Description","NAICS Code","NAICS Description","Pollutant","Emissions in Tons","Year"

# Example:
# OTAY LANDFILL INC,1700 MAXWELL RD Chula Vista CA 91910-0000,32.59808,-117.01699,4953,Electric, Gas And Sanitary Services Sanitary Services Refuse Systems,562920,Materials Recovery Facilities,PM10,483.16,2005

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