http = require "http"
url = require "url"
util = require "util"
fs = require "fs"

# http://www.epa.gov/cgi-bin/broker?area=CA&secnum=01&pol=Toxic&emisamt=500&button=Create+CSV+File&_debug=0&_service=data&_program=dataprog.ge_button_2008.sas

console.log "Grabbing data from the EPA"

level = "100"

for state in ["AK","AL","AR","AZ","CA","CO","CT","DC","DE","FL","GA","HI","IA","ID","IL","IN","KS","KY","LA","MA","MD","ME","MI","MN","MO","MS","MT","NC","ND","NE","NH","NJ","NM","NV","NY","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VA","VT","WA","WI","WV","WY"]
  do (state) ->
    console.log "Starting #{state}"
    path = "/cgi-bin/broker?area=#{state}&secnum=01&pol=Toxic&emisamt=#{level}&button=Create+CSV+File&_debug=0&_service=data&_program=dataprog.ge_button_2008.sas"
    # console.log path

    file = fs.createWriteStream "data/#{state}.#{level}.csv"

    request = http.get { host: "www.epa.gov", port: 80, path: path}, (response) ->
      response.on "data", (chunk) ->
        file.write chunk, "binary"
      response.on "end", (chunk) ->
        file.addListener "drain", ->
          console.log "Finished #{state}"
          file.end
    request.end()





# http://www.epa.gov/cgi-bin/broker?area=CA&secnum=01&pol=Toxic&emisamt=500&button=Create+CSV+File&_debug=0&_service=data&_program=dataprog.ge_button_2008.sas