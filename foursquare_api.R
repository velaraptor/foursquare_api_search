##foursquare api
client_id="CLIENT_ID"
client_secret="CLIENT_SECRET"
v="20160101"
query="QUERY"
radius=10000
##==============================================
##list of city names to query
near.df=read.csv("Desktop/Texas_Cities.csv",header=FALSE)
near.df[,1]<-as.character(near.df[,1])
near.df[,2]<-"TX"
##==============================================
##get lat/lon of city centers
library(rgeos)
library(rgdal)
library(httr)
library(dplyr)
geo_init <- function() {

  try({
    GET("http://www.mapcruzin.com/fcc-wireless-shapefiles/cities-towns.zip",
        write_disk("cities.zip"))
    unzip("cities.zip", exdir="cities") })

  shp <- readOGR("cities/citiesx020.shp", "citiesx020")

  geo <-
    gCentroid(shp, byid=TRUE) %>%
    data.frame() %>%
    rename(lon=x, lat=y) %>%
    mutate(city=shp@data$NAME, state=shp@data$STATE)

}

geocode <- function(geo_db, city, state) {
  do.call(rbind.data.frame, mapply(function(x, y) {
    geo_db %>% filter(city==x, state==y)
  }, city, state, SIMPLIFY=FALSE))
}
geo_db <- geo_init()


tx=geo_db %>% geocode(near.df[,1],near.df[,2])
ll=paste0(tx$lat,",",tx$lon)

##==============================================
foursquare<-function(client_id,client_secret,v,query,radius,near.df){
	foursquare.list<-list();
	require(jsonlite);
	for(i in 1:length(near.df)){
		near=near.df[i];
		fqs.query=paste0("https://api.foursquare.com/v2/venues/search?client_id=",client_id,
  							"&client_secret=",client_secret,
 							"&intent=browse",
  							"&v=",v,
  							"&radius=",radius,
 							"&ll=",near,
 							"&query=",query);
		fqs.request=readLines(fqs.query);
		foursquare.list[[i]]<-fromJSON(fqs.request,simplifyDataFrame=TRUE);
		Sys.sleep(20);
	}
	return(foursquare.list);
}
##==============================================
texas_vets=foursquare(client_id,client_secret,v,query,radius,ll)
##==============================================
get_business<-function(list){
	return(list$response$venues)
}

tx_animals<-lapply(texas_vets,get_business)
tx_animals<-lapply(tx_animals,flatten)

require(plyr)
tx_animals_1<-rbind.fill(lapply(tx_animals,function(y){as.data.frame((y),stringsAsFactors=FALSE)}))
tx_animals_1<-tx_animals_1[!duplicated(tx_animals_1$id),]
