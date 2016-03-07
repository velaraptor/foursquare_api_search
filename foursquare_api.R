##created by velaraptor 2016
##foursquare api
client_id="CLIENT_ID"
client_secret="CLIENT_SECRET"
v="20160101"
query="QUERY"
radius=10000
##==============================================
##downloaded from https://developers.google.com/adwords/api/docs/appendix/geotargeting?csw=1
##this is a big file
cities<-read.csv("files/cities_google.csv")
states<-read.csv("files/states_google.csv")

states<-states[,-4]
names(states)[1]<-"Parent.ID"
city.state<-merge(cities,states,by="Parent.ID",all=TRUE)
city.state<-city.state[,-c(9,10,11,12)]
names(city.state)<-c("Parent.ID","Criteria.ID","City","Canonical.Name","County.Code","Target", "Status","State")

abb<-read.csv("files/abbreviations.csv")

city_state<-merge(city.state,abb,by="State")
city_state[,10]<-as.character(city_state[,10])
city_state[,4]<-as.character(city_state[,4])
##==============================================
##get lat/lon of city centers
require(rgeos)
require(rgdal)
require(httr)
require(dplyr)
##code from http://stackoverflow.com/questions/27867846/quick-way-to-get-longitude-latitude-from-city-state-input
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


all_cities=geo_db %>% geocode(near.df[,1],near.df[,2])
ll=paste0(all_cities$lat,",",all_cities$lon)

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
all_vets=foursquare(client_id,client_secret,v,query,radius,ll)
##==============================================
get_business<-function(list){
	return(list$response$venues)
}

all_animals<-lapply(all_vets,get_business)
all_animals<-lapply(all_animals,flatten)

require(plyr)
all_animals_1<-rbind.fill(lapply(all_animals,function(y){as.data.frame((y),stringsAsFactors=FALSE)}))
all_animals_1<-all_animals_1[!duplicated(all_animals_1$id),]
