# Foursquare API Search for R 
##Foursquare API search for R that uses all cities in the United States provided by Google Adwords API. 


To use this API search provide your client ID and Client Secret. The "v" parameter equals the date in YYYYMMDD format to the moment you want to query. The query parameter is what you would want to search for (i.e. "coffee shop"). Radius is the length in meters that you want to do your search. 
```
client_id="CLIENT_ID"
client_secret="CLIENT_SECRET"
v="20160101"
query="QUERY"
radius=10000
```

To subset specific states you can subset based on the code below:
```
test<-subset(all_cities, state %in% c("NY","CA","IL","TX"))
```
####For more information concerning the Foursquare API check out: https://developer.foursquare.com/docs/venues/search
##Currently making a package to query foursquare. 
