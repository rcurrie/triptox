# triptox
HTML5 mobile web application that shows polution emitters on up to three routes

## Demo
[http://triptox.ampdat.com](http://triptox.ampdat.com)

## Motivation
http://www.epa.gov/appsfortheenvironment/

## Data Source
http://www.epa.gov/air/emissions/where.htm

## Setting up the server
install mongodb
install nodejs and npm
npm install coffee-script underscore connect mongoose ya-csv

## Importing the data
coffee import.coffee

## Running the server
coffee server.coffee

## Hacking the server
npm -g install supervisor
supervisor server.coffee

## Technologies
* Coffeescript
* Nodejs
* Mondgodb
* Jquery Mobile
* Backbonejs
* Underscore