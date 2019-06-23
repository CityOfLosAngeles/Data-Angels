## Install and set up all the packages

#install.packages(c("ggplot2", "devtools", "dplyr", "stringr"))
#install.packages(c("maps", "mapdata")) #standard map packages
#install.packages("zipcode") #install ZIP code to lat-long database
#install.packages("choroplethr") #choropleth maker
#install.packages("devtools")
#install.packages("tigris") #zcta boundaries
#install.packages("viridis") #better color palette
#install.packages("scales") #better labels on legend
#devtools::install_github("dkahle/ggmap") #ggmap, github source
#install.packages("googleway") # interactive google maps
#install.packages("ggpol")
#install.packages("geosphere")
#install.packages("ggrepel")
#install.packages("rgdal")
#install.packages("raster")
#install.packages("cowplot")

## Load from library

library(ggplot2)
library(ggmap)
library(maps)
library(mapdata)
library(stringr)
library(dplyr)
library(devtools)
install_github('arilamstein/choroplethrZip@v1.5.0') #dataframe with ZCTA boundaries
library(choroplethrZip)
library(viridis)
library(scales)
library(googleway)
library(ggpol)
library(geosphere) # computes distances between two sets of coordinates
library(ggrepel) # makes it easier to add labels
library(rgdal) # use to upload shapefiles
library(raster) # maybe a different way to upload shapefiles
library(cowplot) # allows you to plot multiple plots side by side
## import rental data

setwd("~/Documents/Data Angels/")
rent <- read.csv("zri_mfr_rent.csv")
head(rent)
rent <- subset(rent, City == "Los Angeles") # drop all rows that aren't LA neighborhoods
head(rent)
tail(rent)

# rename neighborhoods in Zillow data to match LA Times neighborhood names
rent$id <- rent$RegionName # create duplicate column
rent <- rent[,c(1:2,109,3:108)] # rearrange columns
head(rent$id, n = 150)
rent$id <- as.character(rent$id)
rent$id[rent$id == "Bel Air"] <- "Bel-Air"
rent$id[rent$id == "Crenshaw"] <- "Baldwin Hills/Crenshaw"
rent$id[rent$id == "Playa Del Rey"] <- "Playa del Rey"
rent$id[rent$id == "Lakeview Terrace"] <- "Lake View Terrace"
rent$id[rent$id == "Central City"] <- "Historic South-Central"
rent$id[rent$id == "Cahuenga Pass"] <- "Hollywood Hills West"
rent1 <- rent[80,] # replicate South Los Angeles row as separate dataframe
head(rent1)
rent1$id[rent1$id == "South Los Angeles"] <- "Chesterfield Square"
rent <- rbind(rent, rent1) # bind new Chesterfield Square row to the original Zillow dataset
head(rent$id, n = 100) # nice it works
rent1 <- rent[80,]
rent1$id[rent1$id == "South Los Angeles"] <- "Exposition Park"
rent <- rbind(rent, rent1)
rent1 <- rent[80,]
rent1$id[rent1$id == "South Los Angeles"] <- "Harvard Park"
rent <- rbind(rent, rent1)
rent1 <- rent[80,]
rent1$id[rent1$id == "South Los Angeles"] <- "Manchester Square"
rent <- rbind(rent, rent1)
rent1 <- rent[80,]
rent1$id[rent1$id == "South Los Angeles"] <- "Adams-Normandie"
rent <- rbind(rent, rent1)
rent1 <- rent[80,]
rent1$id[rent1$id == "South Los Angeles"] <- "University Park"
rent <- rbind(rent, rent1)
rent1 <- rent[80,]
rent1$id[rent1$id == "South Los Angeles"] <- "Vermont Knolls"
rent <- rbind(rent, rent1)
rent1 <- rent[80,]
rent1$id[rent1$id == "South Los Angeles"] <- "Vermont-Slauson"
rent <- rbind(rent, rent1)
rent1 <- rent[80,]
rent1$id[rent1$id == "South Los Angeles"] <- "Vermont Square"
rent <- rbind(rent, rent1)
rent1 <- rent[80,]
rent1$id[rent1$id == "South Los Angeles"] <- "Vermont Vista"
rent <- rbind(rent, rent1)
rent1 <- rent[80,]
rent1$id[rent1$id == "South Los Angeles"] <- "Gramercy Park"
rent <- rbind(rent, rent1)
head(rent$id, n = 150) # nice it works
rent1 <- rent[29,] # replicate Hollywood row as separate dataframe
rent1$id[rent1$id == "Hollywood"] <- "East Hollywood"
rent <- rbind(rent, rent1)
rent1 <- rent[38,] # replicate Harvard Heights row as separate dataframe
rent1$id[rent1$id == "Harvard Heights"] <- "Arlington Heights"
rent <- rbind(rent, rent1)
rent1 <- rent[47,] # replicate Chatsworth row as separate dataframe
rent1$id[rent1$id == "Chatsworth"] <- "Chatsworth Reservoir"
rent <- rbind(rent, rent1)
rent1 <- rent[68,] # replicate Lakeview Terrace row as separate dataframe
rent1$id[rent1$id == "Lake View Terrace"] <- "Hansen Dam"
rent <- rbind(rent, rent1)
rent1 <- rent[10,] # replicate Cheviot Hills row as separate dataframe
rent1$id[rent1$id == "Cheviot Hills"] <- "Rancho Park"
rent <- rbind(rent, rent1)
rent1 <- rent[61,] # replicate Encino row as separate dataframe
rent1$id[rent1$id == "Encino"] <- "Sepulveda Basin"
rent <- rbind(rent, rent1)
rent1 <- rent[82,] # replicate Southeast Los Angeles row as separate dataframe
rent1$id[rent1$id == "Southeast Los Angeles"] <- "Broadway-Manchester"
rent <- rbind(rent, rent1)
rent1 <- rent[82,]
rent1$id[rent1$id == "Southeast Los Angeles"] <- "Florence"
rent <- rbind(rent, rent1)
rent1 <- rent[82,]
rent1$id[rent1$id == "Southeast Los Angeles"] <- "Green Meadows"
rent <- rbind(rent, rent1)
rent1 <- rent[82,]
rent1$id[rent1$id == "Southeast Los Angeles"] <- "South Park"
rent <- rbind(rent, rent1)
rent1 <- rent[82,]
rent1$id[rent1$id == "Southeast Los Angeles"] <- "Central-Alameda"
rent <- rbind(rent, rent1)
rent1 <- rent[27,] # replicate Mid Wilshire row as separate dataframe
rent1$id[rent1$id == "Mid Wilshire"] <- "Larchmont"
rent <- rbind(rent, rent1)
rent1 <- rent[27,]
rent1$id[rent1$id == "Mid Wilshire"] <- "Hancock Park"
rent <- rbind(rent, rent1)
rent1 <- rent[27,]
rent1$id[rent1$id == "Mid Wilshire"] <- "Windsor Square"
rent <- rbind(rent, rent1)
rent1 <- rent[11,] # replicate Mid City West row as separate dataframe
rent1$id[rent1$id == "Mid City West"] <- "Fairfax"
rent <- rbind(rent, rent1)
rent1 <- rent[11,]
rent1$id[rent1$id == "Mid City West"] <- "Carthay"
rent <- rbind(rent, rent1)
rent1 <- rent[11,]
rent1$id[rent1$id == "Mid City West"] <- "Beverly Grove"
rent <- rbind(rent, rent1)
rent1 <- rent[28,]
rent1$id[rent1$id == "Mid City"] <- "Mid-Wilshire"
rent <- rbind(rent, rent1)
rent1 <- rent[28,]
rent1$id[rent1$id == "Mid City"] <- "Mid-City"
rent <- rbind(rent, rent1)
rent1 <- rent[44,]
rent1$id[rent1$id == "Downtown"] <- "Chinatown"
rent <- rbind(rent, rent1)
head(rent$id, n = 150) 
head(rent$RegionName, n = 150) # nice it works
tail(rent) # ya boi

# add columns that define regions / aggregations of neighborhoods
id_names <- read.csv("name_match.csv")
head(id_names)
id_names <- id_names[c(1,3,4)]
id_names$id <- as.character(id_names$id)
rent <- rent %>%
  inner_join(id_names, by = "id")
head(rent)

# create smaller rent dataframe, with annual March rents only
march_rent <- rent[c(2, 3, 13, 25, 37, 49, 61, 73, 85, 97, 109, 110, 111)]
march_rent <- march_rent[,c(1:2,12:13,3:11)] # rearrange columns
head(march_rent, n = 30)

# adjust rent values for inflation, using CPI less food and energy
march_rent$X2011.03 <- march_rent$X2011.03*1.17
march_rent$X2012.03 <- march_rent$X2012.03*1.144
march_rent$X2013.03 <- march_rent$X2013.03*1.123
march_rent$X2014.03 <- march_rent$X2014.03*1.105
march_rent$X2015.03 <- march_rent$X2015.03*1.086
march_rent$X2016.03 <- march_rent$X2016.03*1.063
march_rent$X2017.03 <- march_rent$X2017.03*1.042
march_rent$X2018.03 <- march_rent$X2018.03*1.021
head(march_rent, n = 30)

march_rent$increase_1119 <- (march_rent$X2019.03 - march_rent$X2011.03)
march_rent$pct_increase_1119 <- (march_rent$X2019.03 - march_rent$X2011.03)/(march_rent$X2011.03)
march_rent$increase_1113 <- (march_rent$X2013.03 - march_rent$X2011.03)
march_rent$increase_1315 <- (march_rent$X2015.03 - march_rent$X2013.03)
march_rent$increase_1517 <- (march_rent$X2017.03 - march_rent$X2015.03)
march_rent$increase_1719 <- (march_rent$X2019.03 - march_rent$X2017.03)
march_rent$pct_increase_1113 <- (march_rent$X2013.03 - march_rent$X2011.03)/(march_rent$X2011.03)
march_rent$pct_increase_1315 <- (march_rent$X2015.03 - march_rent$X2013.03)/(march_rent$X2013.03)
march_rent$pct_increase_1517 <- (march_rent$X2017.03 - march_rent$X2015.03)/(march_rent$X2015.03)
march_rent$pct_increase_1719 <- (march_rent$X2019.03 - march_rent$X2017.03)/(march_rent$X2017.03)
head(march_rent, n = 30)
tail(march_rent, n = 30)

## import LA neighborhood boundaries

file.exists("LA_Times_Neighborhoods.shp")
#neighborhood <- shapefile("~/Documents/Data Angels/LA_Times_Neighborhoods.shp")
neighborhood <- readOGR(dsn = "~/Documents/Data Angels/LA_Times_Neighborhoods", layer = "LA_Times_Neighborhoods")
head(neighborhood)
nh_df <- broom::tidy(neighborhood, region = "name") # turn into a dataframe
lapply(nh_df, class)
head(nh_df)
nh_names <- aggregate(cbind(long, lat) ~ id, data=nh_df, FUN=mean) # create dataframe with names of neighborhoods
head(nh_names)

## create Google Map

#set_key("***REMOVED***", api = "geocode")
#set_key("***REMOVED***", api = "map")
#set_key("***REMOVED***", api = "default")
#google_keys() # check to see which API keys are active
register_google(key = "xxx")

# plot our standard map of LA
la_map <- get_map(location = c(lon=-118.31, lat=34.0),  maptype = "roadmap", source = "google", zoom = 10) # map of los angeles
ggmap(la_map)

# put the neighborhood boundaries on the map
map2 <- ggmap(la_map) + 
  geom_polygon(data = nh_df, aes(x = long, y = lat, group = group), fill = NA, linetype = "21", size = 0.2, color = "black") # YUUUS it works
map2 # map of LA with neighborhood boundaries

map3 <- map2 +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2)
map3 # map of LA with neighborhood boundaries and labels

## combine neighborhood shapefile with Zillow rental data

combined <- nh_df %>% inner_join(march_rent, by = "id") # join the data frames
head(combined)

# create map with fill based on March 2019 rental prices
map4 <- ggmap(la_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2019.03, c(0,1500,2000,2500,3000,3500,4000,6500), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
map4

## create close-up maps by neighborhood

# Westside
#westside_map <- get_map(location = c(lon=-118.43, lat=34.02),  maptype = "roadmap", source = "google", zoom = 12) # map of los angeles
#ggmap(westside_map)

westside_map <- get_map(location = c(lon=-118.42, lat=34.05),  maptype = "roadmap", source = "google", zoom = 11) # map of los angeles
ggmap(westside_map)

westside2 <- ggmap(westside_map) + 
  geom_polygon(data = nh_df, aes(x = long, y = lat, group = group), fill = NA, linetype = "21", size = 0.2, color = "black") # YUUUS it works
westside2

westside3 <- westside2 +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2)
westside3

westside4 <- ggmap(westside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2019.03, c(0,1500,2000,2500,3000,3500,4000,6500), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.53, -118.33), ylim = c(33.92, 34.12), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
westside4

# Eastside
eastside_map <- get_map(location = c(lon=-118.25, lat=34.08),  maptype = "roadmap", source = "google", zoom = 11) # map of los angeles
ggmap(eastside_map)

eastside2 <- ggmap(eastside_map) + 
  geom_polygon(data = nh_df, aes(x = long, y = lat, group = group), fill = NA, linetype = "21", size = 0.2, color = "black") # YUUUS it works
eastside2

eastside3 <- eastside2 +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2)
eastside3

eastside4 <- ggmap(eastside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2019.03, c(0,1500,2000,2500,3000,3500,4000,6500), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.35, -118.15), ylim = c(33.98, 34.18), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
eastside4

# Valley
valley_map <- get_map(location = c(lon=-118.45, lat=34.2),  maptype = "roadmap", source = "google", zoom = 11) # map of los angeles
ggmap(valley_map)

valley2 <- ggmap(valley_map) + 
  geom_polygon(data = nh_df, aes(x = long, y = lat, group = group), fill = NA, linetype = "21", size = 0.2, color = "black") # YUUUS it works
valley2

valley3 <- valley2 +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2)
valley3

valley4 <- ggmap(valley_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2019.03, c(0,1500,2000,2500,3000,3500,4000,6500), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
valley4

# South LA
southla_map <- get_map(location = c(lon=-118.28, lat=33.95),  maptype = "roadmap", source = "google", zoom = 11) # map of los angeles
ggmap(southla_map)

southla2 <- ggmap(southla_map) + 
  geom_polygon(data = nh_df, aes(x = long, y = lat, group = group), fill = NA, linetype = "21", size = 0.2, color = "black") # YUUUS it works
southla2

southla3 <- southla2 +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2)
southla3

southla4 <- ggmap(southla_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2019.03, c(0,1500,2000,2500,3000,3500,4000,6500), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.38, -118.18), ylim = c(33.85, 34.05), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
southla4

## create % chg from Mar 2011 to Mar 2019

map5 <- ggmap(la_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1119, c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
map5

westside5 <- ggmap(westside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1119, c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.53, -118.33), ylim = c(33.92, 34.12), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
westside5

eastside5 <- ggmap(eastside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1119, c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.35, -118.15), ylim = c(33.98, 34.18), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
eastside5

valley5 <- ggmap(valley_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1119, c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
valley5

southla5 <- ggmap(southla_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1119, c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.38, -118.18), ylim = c(33.85, 34.05), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
southla5

## create % chg from Mar 2011 to Mar 2013

map6 <- ggmap(la_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1113, c(-0.2,-0.15,-0.1,-0.05,0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
map6

westside6 <- ggmap(westside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1113, c(-0.2,-0.15,-0.1,-0.05,0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.53, -118.33), ylim = c(33.92, 34.12), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
westside6

eastside6 <- ggmap(eastside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1113, c(-0.2,-0.15,-0.1,-0.05,0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.35, -118.15), ylim = c(33.98, 34.18), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
eastside6

valley6 <- ggmap(valley_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1113, c(-0.2,-0.15,-0.1,-0.05,0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
valley6

southla6 <- ggmap(southla_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1113, c(-0.2,-0.15,-0.1,-0.05,0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.38, -118.18), ylim = c(33.85, 34.05), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
southla6

## create % chg from Mar 2013 to Mar 2015

map7 <- ggmap(la_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1315, c(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
map7

westside7 <- ggmap(westside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1315, c(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.53, -118.33), ylim = c(33.92, 34.12), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
westside7

eastside7 <- ggmap(eastside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1315, c(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.35, -118.15), ylim = c(33.98, 34.18), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
eastside7

valley7 <- ggmap(valley_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1315, c(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
valley7

southla7 <- ggmap(southla_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1315, c(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.38, -118.18), ylim = c(33.85, 34.05), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
southla7

## create % chg from Mar 2015 to Mar 2017

map8 <- ggmap(la_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1517, c(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
map8

westside8 <- ggmap(westside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1517, c(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.53, -118.33), ylim = c(33.92, 34.12), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
westside8

eastside8 <- ggmap(eastside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1517, c(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.35, -118.15), ylim = c(33.98, 34.18), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
eastside8

valley8 <- ggmap(valley_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1517, c(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
valley8

southla8 <- ggmap(southla_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1517, c(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.38, -118.18), ylim = c(33.85, 34.05), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
southla8

## create % chg from Mar 2017 to Mar 2019

map9 <- ggmap(la_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1719, c(-0.1,-0.05,0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
map9

westside9 <- ggmap(westside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1719, c(-0.1,-0.05,0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.53, -118.33), ylim = c(33.92, 34.12), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
westside9

eastside9 <- ggmap(eastside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1719, c(-0.1,-0.05,0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.35, -118.15), ylim = c(33.98, 34.18), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
eastside9

valley9 <- ggmap(valley_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1719, c(-0.1,-0.05,0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
valley9

southla9 <- ggmap(southla_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(pct_increase_1719, c(-0.1,-0.05,0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,2), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.38, -118.18), ylim = c(33.85, 34.05), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate", palette=8) 
southla9

## create point-in-time views in 2011, 2014, 2017, 2019

la2011 <- ggmap(la_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, 
        fill = cut(X2011.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
        c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2011", palette=8, drop = F) 
la2011

la2014 <- ggmap(la_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, 
        fill = cut(X2014.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
        c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2014", palette=8, drop = F) 
la2014

la2017 <- ggmap(la_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, 
                                    fill = cut(X2017.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                               c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2017", palette=8, drop = F) 
la2017

la2019 <- ggmap(la_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, 
                                    fill = cut(X2019.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                               c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2019", palette=8, drop = F) 
la2019

la_row <- plot_grid( la2011 + theme(legend.position="none"),
                     la2014 + theme(legend.position="none"),
                     la2017 + theme(legend.position="none"),
                     la2019 + theme(legend.position="none"),
                             align = 'vh',
                             labels = c("2011", "2014", "2017", "2019"),
                             hjust = -1,
                             nrow = 1)
la_row

westside2011 <- ggmap(westside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2011.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.53, -118.33), ylim = c(33.92, 34.12), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2011", palette=8, drop = F) 
westside2011

westside2014 <- ggmap(westside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2014.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.53, -118.33), ylim = c(33.92, 34.12), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2014", palette=8, drop = F) 
westside2014

westside2017 <- ggmap(westside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2017.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.53, -118.33), ylim = c(33.92, 34.12), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2017", palette=8, drop = F) 
westside2017

westside2019 <- ggmap(westside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2019.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.53, -118.33), ylim = c(33.92, 34.12), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2019", palette=8, drop = F) 
westside2019

eastside2011 <- ggmap(eastside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2011.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.35, -118.15), ylim = c(33.98, 34.18), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2011", palette=8, drop = F) 
eastside2011

eastside2014 <- ggmap(eastside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2014.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.35, -118.15), ylim = c(33.98, 34.18), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2014", palette=8, drop = F) 
eastside2014

eastside2017 <- ggmap(eastside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2017.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.35, -118.15), ylim = c(33.98, 34.18), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2017", palette=8, drop = F) 
eastside2017

eastside2019 <- ggmap(eastside_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2019.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.35, -118.15), ylim = c(33.98, 34.18), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2019", palette=8, drop = F) 
eastside2019

valley2011 <- ggmap(valley_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2011.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2011", palette=8, drop = F) 
valley2011

valley2014 <- ggmap(valley_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2014.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2014", palette=8, drop = F) 
valley2014

valley2017 <- ggmap(valley_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2017.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2017", palette=8, drop = F) 
valley2017

valley2019 <- ggmap(valley_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2019.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2019", palette=8, drop = F) 
valley2019

southla2011 <- ggmap(southla_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2011.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.38, -118.18), ylim = c(33.85, 34.05), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2011", palette=8, drop = F) 
southla2011

southla2014 <- ggmap(southla_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2014.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.38, -118.18), ylim = c(33.85, 34.05), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2014", palette=8, drop = F) 
southla2014

southla2017 <- ggmap(southla_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2017.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.38, -118.18), ylim = c(33.85, 34.05), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2017", palette=8, drop = F) 
southla2017

southla2019 <- ggmap(southla_map) + 
  geom_polygon(data = combined, aes(x = long, y = lat, group = group, fill = cut(X2019.03, c(0,1650,2000,2250,2500,2750,3000,3500,4000,7000), 
                                                                                 c("<$1,650","$1,650-$1,999","$2,000-2,249","$2,250-2,499","$2,500-2,749","$2,750-2,999","$3,000-3,499","$3,500-3,999","$4,000+"), include.lowest = F, dig.lab=10)), linetype = "21", size = 0.2, color = "black") +
  coord_fixed(xlim = c(-118.38, -118.18), ylim = c(33.85, 34.05), ratio = 1.1) +
  geom_text(data = nh_names, aes(x = long, y = lat, label = id), size = 2) +
  scale_fill_brewer(name = "Monthly Rent Estimate, 2019", palette=8, drop = F) 
southla2019

# now export these sick ass maps
ggsave(filename="la_mar2019.png", plot=map4)
ggsave(filename="westside_mar2019.png", plot=westside4)
ggsave(filename="eastside_mar2019.png", plot=eastside4)
ggsave(filename="valley_mar2019.png", plot=valley4)
ggsave(filename="southla_mar2019.png", plot=southla4)
ggsave(filename="la_pct_change_1119.png", plot=map5)
ggsave(filename="westside_pct_change_1119.png", plot=westside5)
ggsave(filename="eastside_pct_change_1119.png", plot=eastside5)
ggsave(filename="valley_pct_change_1119.png", plot=valley5)
ggsave(filename="southla_pct_change_1119.png", plot=southla5)
ggsave(filename="la_pct_change_1113.png", plot=map6)
ggsave(filename="westside_pct_change_1113.png", plot=westside6)
ggsave(filename="eastside_pct_change_1113.png", plot=eastside6)
ggsave(filename="valley_pct_change_1113.png", plot=valley6)
ggsave(filename="southla_pct_change_1113.png", plot=southla6)
ggsave(filename="la_pct_change_1315.png", plot=map7)
ggsave(filename="westside_pct_change_1315.png", plot=westside7)
ggsave(filename="eastside_pct_change_1315.png", plot=eastside7)
ggsave(filename="valley_pct_change_1315.png", plot=valley7)
ggsave(filename="southla_pct_change_1315.png", plot=southla7)
ggsave(filename="la_pct_change_1517.png", plot=map8)
ggsave(filename="westside_pct_change_1517.png", plot=westside8)
ggsave(filename="eastside_pct_change_1517.png", plot=eastside8)
ggsave(filename="valley_pct_change_1517.png", plot=valley8)
ggsave(filename="southla_pct_change_1517.png", plot=southla8)
ggsave(filename="la_pct_change_1719.png", plot=map9)
ggsave(filename="westside_pct_change_1719.png", plot=westside9)
ggsave(filename="eastside_pct_change_1719.png", plot=eastside9)
ggsave(filename="valley_pct_change_1719.png", plot=valley9)
ggsave(filename="southla_pct_change_1719.png", plot=southla9)
ggsave(filename="la2011.png", plot=la2011)
ggsave(filename="la2014.png", plot=la2014)
ggsave(filename="la2017.png", plot=la2017)
ggsave(filename="la2019.png", plot=la2019)
ggsave(filename="westside2011.png", plot=westside2011)
ggsave(filename="westside2014.png", plot=westside2014)
ggsave(filename="westside2017.png", plot=westside2017)
ggsave(filename="westside2019.png", plot=westside2019)
ggsave(filename="eastside2011.png", plot=eastside2011)
ggsave(filename="eastside2014.png", plot=eastside2014)
ggsave(filename="eastside2017.png", plot=eastside2017)
ggsave(filename="eastside2019.png", plot=eastside2019)
ggsave(filename="valley2011.png", plot=valley2011)
ggsave(filename="valley2014.png", plot=valley2014)
ggsave(filename="valley2017.png", plot=valley2017)
ggsave(filename="valley2019.png", plot=valley2019)
ggsave(filename="southla2011.png", plot=southla2011)
ggsave(filename="southla2014.png", plot=southla2014)
ggsave(filename="southla2017.png", plot=southla2017)
ggsave(filename="southla2019.png", plot=southla2019)
