#LA City Data
#setwd("/Users/alfonsoberumen/Desktop/City Files")
#Census data using tidycensus
#install.packages("tidycensus")
#library(tidycensus)
#install.packages("censusapi")
library(censusapi)
library(tidyverse)
library(dplyr)
library(tigris)
#install.packages("leaflet.extras")
library(leaflet.extras)
library(tidyr)

#set working directory
setwd("/Users/alfonsoberumen/Desktop/City Files/SOCRATA")

######################
#shape file
######################
library(sf)
library(rgdal)
shape <-rgdal::readOGR("/Users/alfonsoberumen/Desktop/City Files/SOCRATA/LA_Times_Neighborhoods.shp")
str(shape)

######################
#households
######################
hhs<-read.csv("Households__LA_.csv",header=TRUE)
glimpse(hhs)
table(hhs$Year)#2010 to 2017
table(hhs$Variable)

hhs_count<- hhs %>%
  filter(Variable!="Average Household Size") %>%
  group_by(GEOID,Neighborhood,Year)%>%
  summarise(HHs = sum(as.numeric(Count)), HH_rows = n())

######################
#median rent price
######################
rent<-read.csv("Rent_Price__LA_.csv",header=TRUE)
table(rent$Year)#2010 to 2016
#drop NAs
rent<-rent %>% 
  drop_na(Amount) %>%
  separate(Location, c("Latitude", "Longitude"),sep = ",")%>%
  mutate(Latitude=parse_number(Latitude))%>%
  mutate(Longitude=parse_number(Longitude))
rent_weight<-rent %>%
  inner_join(hhs_count,by=c("GEOID","Neighborhood","Year")) %>%
  drop_na(HHs)
rent_weight<-rent_weight %>%
  dplyr::rename(Median_Rent=Amount,
                HHs_Rent=HHs) %>%
  select(Year,GEOID,Tract.Number,Neighborhood,Latitude,Longitude,HHs_Rent,Median_Rent)
  
######################
#median income
######################
income_detailed<-read.csv("Income__LA_.csv",header=TRUE)
table(income_detailed$Year)#2010 to 2016
#drop NAs
income_detailed<-income_detailed %>% 
  drop_na(Amount) %>%
  separate(Location, c("Latitude", "Longitude"),sep = ",")%>%
  mutate(Latitude=parse_number(Latitude))%>%
  mutate(Longitude=parse_number(Longitude))
income_weight<-income_detailed %>%
  inner_join(hhs_count,by=c("GEOID","Neighborhood","Year"))%>%
  drop_na(HHs) 
glimpse(income_detailed)

income_weight<-income_weight %>%
  dplyr::rename(Median_Income=Amount,
                Income_HHs=HHs) %>%
  select(Year,GEOID,Tract.Number,Neighborhood,Latitude,Longitude,Income_HHs,Median_Income)
  
########################
#unemployment rate
########################
employ<-read.csv("Employment__LA_.csv",header=TRUE)
glimpse(employ)
table(employ$Year)#2010 to 2017
#just keep unemployment rate
unemploy<-employ %>% 
  filter(Variable=="Unemployment Rate")
#drop NAs
unemploy<-unemploy %>% 
  drop_na(Percent) %>%
  separate(Location, c("Latitude", "Longitude"),sep = ",")%>%
  mutate(Latitude=parse_number(Latitude))%>%
  mutate(Longitude=parse_number(Longitude))

unemploy_weight<-unemploy %>%
  dplyr::rename(Unemploy_Count=Count,
                Labor_Force_Pop=Denominator) %>%
  select(Year,GEOID,Tract.Number,Neighborhood,Latitude,Longitude,Labor_Force_Pop,Unemploy_Count)

#########################
#Rent burden
#########################
burden<-read.csv("Rent_Burden__LA_.csv",header=TRUE)
table(burden$Year)#2010 to 2017
#drop NAs
burden<- burden %>% 
  drop_na(Percent) %>%
  separate(Location, c("Latitude", "Longitude"),sep = ",")%>%
  mutate(Latitude=parse_number(Latitude))%>%
  mutate(Longitude=parse_number(Longitude))

burden_weight<-burden %>%
  dplyr::rename(Burden_Count=Count,
                Renter_Households=Denominator) %>%
  select(Year,GEOID,Tract.Number,Neighborhood,Latitude,Longitude,Renter_Households,Burden_Count)

#########################
#Overcrowding
#########################
over<-read.csv("Overcrowding__LA_.csv",header=TRUE)
table(over$Year)#2010 to 2017
#drop NAs
over<-over %>% 
  drop_na(Percent) %>%
  separate(Location, c("Latitude", "Longitude"),sep = ",")%>%
  mutate(Latitude=parse_number(Latitude))%>%
  mutate(Longitude=parse_number(Longitude))

over_weight<-over %>%
  dplyr::rename(Overcrowd_Count=Count,
                Total_Households=Denominator) %>%
  select(Year,GEOID,Tract.Number,Neighborhood,Latitude,Longitude,Total_Households,Overcrowd_Count)

#########################
#Housing Stability
#########################
stab<-read.csv("Housing_Stability__LA_.csv",header=TRUE)
table(stab$Year)#2010 to 2017
GEOID<-as.data.frame(table(stab$GEOID))
table(stab$Variable)#Includes only number of stable HHs
stab<-stab %>% 
  drop_na(Percent) %>%
  separate(Location, c("Latitude", "Longitude"),sep = ",")%>%
  mutate(Latitude=parse_number(Latitude))%>%
  mutate(Longitude=parse_number(Longitude))

stab_weight<-stab %>%
  dplyr::rename(Stability_Count=Count,
                Pov_Pop_Above_One_Year=Denominator) %>%
  select(Year,GEOID,Tract.Number,Neighborhood,Latitude,Longitude,Stability_Count,Pov_Pop_Above_One_Year)

#########################
#Race/Ethinicity
#########################
race<-read.csv("Race___Ethnicity__LA_.csv",header=TRUE)
table(burden$Year)#2010 to 2016
GEOID<-as.data.frame(table(race$GEOID))
race<-race %>%
  drop_na(Percent) %>%
  separate(Location, c("Latitude", "Longitude"),sep = ",")%>%
  mutate(Latitude=parse_number(Latitude))%>%
  mutate(Longitude=parse_number(Longitude))

race_weight<-race %>%
  dplyr::rename(Race_Count=Count,
                Race=Variable) %>%
  select(Year,GEOID,Tract.Number,Neighborhood,Latitude,Longitude,Race,Race_Count)

#transpose race counts
library(reshape2)
race_wide <- reshape2::dcast(race_weight, 
                  Year +
                  GEOID +
                  Tract.Number +
                  Neighborhood +
                  Latitude +
                  Longitude ~
                  Race,
                  value.var = "Race_Count")

##############################################
#COMBINED FILE
##############################################
#################
#create universe
#################
#race_weight
uni_1<-rent_weight %>%
  select(Year,GEOID,Tract.Number,Neighborhood,Latitude,Longitude)

#income_weight
uni_2<-income_weight %>%
  select(Year,GEOID,Tract.Number,Neighborhood,Latitude,Longitude)

#unemploy_weight
uni_3<-unemploy_weight %>%
  select(Year,GEOID,Tract.Number,Neighborhood,Latitude,Longitude)

#burden_weight
uni_4<-burden_weight %>%
  select(Year,GEOID,Tract.Number,Neighborhood,Latitude,Longitude)

#over_weight
uni_5<-over_weight %>%
  select(Year,GEOID,Tract.Number,Neighborhood,Latitude,Longitude)

#stab_weight
uni_6<-stab_weight %>%
  select(Year,GEOID,Tract.Number,Neighborhood,Latitude,Longitude)

#race_weight
uni_7<-race_weight %>%
  select(Year,GEOID,Tract.Number,Neighborhood,Latitude,Longitude)

#stack data
stacked<-
  bind_rows(uni_1, 
            uni_2,
            uni_3,
            uni_4,
            uni_5,
            uni_6,
            uni_7)

final_stacked<-stacked %>%
  distinct(Year,GEOID,Tract.Number,Neighborhood,Latitude,Longitude,.keep_all = TRUE)

glimpse(final_stacked)
  
#######################
#Combined data
#######################
combined<-final_stacked %>%
  left_join(rent_weight,by=c('Year','GEOID','Tract.Number','Neighborhood','Latitude','Longitude')) %>%
  left_join(income_weight,by=c('Year','GEOID','Tract.Number','Neighborhood','Latitude','Longitude')) %>%
  left_join(unemploy_weight,by=c('Year','GEOID','Tract.Number','Neighborhood','Latitude','Longitude')) %>%
  left_join(burden_weight,by=c('Year','GEOID','Tract.Number','Neighborhood','Latitude','Longitude')) %>%
  left_join(over_weight,by=c('Year','GEOID','Tract.Number','Neighborhood','Latitude','Longitude')) %>%
  left_join(stab_weight,by=c('Year','GEOID','Tract.Number','Neighborhood','Latitude','Longitude')) %>%
  left_join(race_wide,by=c('Year','GEOID','Tract.Number','Neighborhood','Latitude','Longitude'))

#review the distinct values later  
check<-combined %>%
  distinct(Year,GEOID,Neighborhood,.keep_all = TRUE)

##############################################
#MERGE TO LA TIMES NEIGHBORHOOD AND LIMIT DATA
##############################################
library(sp)
coordinates(combined) <- c('Longitude', 'Latitude')
proj4string(combined) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

merge<-sp::over(combined,shape[,"name"])
combined$name <- merge$name
glimpse(combined)

combined_final <- as.data.frame(combined)
glimpse(combined_final)

#LIMIT TO THE CITY OF LOS ANGELES (UNMERGED DATA))
combined_final_LA<- combined_final %>%
  filter(!is.na(name))

#######################
#SUM AND WEIGHT
#######################
weighted_LA_DATA <- combined_final_LA %>%
  group_by(Year,name) %>%
  mutate(Rent_W=Median_Rent*HHs_Rent,
         Income_W=Median_Income*Income_HHs
         ) %>%
  summarize(Rent_W = sum(Rent_W,na.rm = TRUE),
            HHs_Rent = sum(HHs_Rent,na.rm = TRUE),
            Income_W = sum(Income_W,na.rm = TRUE),
            Income_HHs = sum(Income_HHs,na.rm = TRUE),
            Unemploy_Count = sum(Unemploy_Count,na.rm=TRUE),
            Labor_Force_Pop=sum(Labor_Force_Pop,na.rm=TRUE),
            Burden_Count=sum(Burden_Count,na.rm=TRUE),
            Renter_Households=sum(Renter_Households,na.rm=TRUE),
            Overcrowd_Count=sum(Overcrowd_Count,na.rm=TRUE),
            Total_Households=sum(Total_Households,na.rm=TRUE),
            Stability_Count=sum(Stability_Count,na.rm=TRUE),
            Pov_Pop_Above_One_Year=sum(Pov_Pop_Above_One_Year,na.rm=TRUE),
            American.Indian.Native.Population=sum(American.Indian.Native.Population,na.rm=TRUE),
            Asian.Population =sum(Asian.Population ,na.rm=TRUE),
            Black.Population=sum(Black.Population,na.rm=TRUE),
            Hispanic.Population=sum(Hispanic.Population,na.rm=TRUE),
            Native.Hawaiian.Other.Pacific.Islander.Population=sum(Native.Hawaiian.Other.Pacific.Islander.Population,na.rm=TRUE),
            Other.Race.Population=sum(Other.Race.Population,na.rm=TRUE),
            Population.of.Two.or.More.Races=sum(Population.of.Two.or.More.Races,na.rm=TRUE),
            White.Population=sum(White.Population,na.rm=TRUE),
            Total_Population=sum(American.Indian.Native.Population,
                                        Asian.Population,
                                        Black.Population,
                                        Hispanic.Population,
                                        Native.Hawaiian.Other.Pacific.Islander.Population,
                                        Other.Race.Population,
                                        Population.of.Two.or.More.Races,
                                        White.Population,na.rm=TRUE))

            
            
weighted_LA_DATA_final<-weighted_LA_DATA %>%
                        mutate(Weighted_Median_Rent=(Rent_W/HHs_Rent),
                               Weighted_Median_Income=(Income_W/HHs_Rent),
                               Unemployment_Rate=(Unemploy_Count/Labor_Force_Pop),
                               Rent_Burden_Rate=(Burden_Count/Renter_Households),
                               Overcrowded_Rate=(Overcrowd_Count/Total_Households),
                               Stability_Rate=(Stability_Count/Pov_Pop_Above_One_Year),
                               American.Indian.Native_Pct=(American.Indian.Native.Population/
                                 Total_Population),
                               Asian.Population_Pct=(Asian.Population/
                                 Total_Population),
                               Black.Population_Pct=(Black.Population/
                                 Total_Population),
                               Hispanic.Population_Pct=(Hispanic.Population/
                                 Total_Population),
                               Native.Hawaiian.Other.Pacific.Islander.Population_Pct=
                                 (Native.Hawaiian.Other.Pacific.Islander.Population/
                                 Total_Population),
                               Other.Race.Population_Pct=(Other.Race.Population/
                                 Total_Population),
                               Population.of.Two.or.More.Races_Pct=(Population.of.Two.or.More.Races/
                                 Total_Population),
                               White.Population_Pct=(White.Population/Total_Population))
table(weighted_LA_DATA_final$Year)

#sort the data
weighted_LA_DATA_final<-weighted_LA_DATA_final %>%
  arrange(name,Year) %>%
  mutate(ACS_Census_Period=ifelse(Year==2010,"2006-10",
                  ifelse(Year==2011,"2007-11",
                  ifelse(Year==2012,"2008-12",
                  ifelse(Year==2013,"2009-13",
                  ifelse(Year==2014,"2010-14",
                  ifelse(Year==2015,"2011-15",
                  ifelse(Year==2016,"2012-16",
                  ifelse(Year==2017,"2013-17",
                         )))))))))

#export to CSV
write.csv(weighted_LA_DATA_final, 
          file = "weighted_LA_DATA_final.csv")
