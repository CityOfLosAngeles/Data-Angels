#LA City Data
library(tidycensus)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(viridisLite)
library(viridis)
library(tigris)
library(sp)
library(crosstalk)
library(leaflet)
library(leaflet.extras)
library(shiny)
library(shinyWidgets)
library(rsconnect)

setwd("/Users/alfonsoberumen/Desktop/City Files/SOCRATA")
###############
#spatial data
###############
tracts <- tracts(state = 'CA', county = "Los Angeles",cb=TRUE)

#######################
#income data-detailed
#######################
income_detailed<-read.csv("Income__LA_.csv",header=TRUE)
table(income_detailed$Year)#2010 to 2016
GEOID<-as.data.frame(table(income_detailed$GEOID))

income_detailed<-income_detailed %>%
  mutate(Amount=as.numeric(gsub(",","",Amount)))

income_detailed_merged<-sp::merge(tracts,
                                  income_detailed,
                         by.x="AFFGEOID",
                         by.y="GEOID",
                         duplicateGeoms = T)

#######################
#rent data-detailed
#######################
rent<-read.csv("Rent_Price__LA_.csv",header=TRUE)
table(rent$Year)#2010 to 2016
GEOID<-as.data.frame(table(rent$GEOID))

rent<-rent %>%
  mutate(Amount=as.numeric(gsub(",","",Amount)))

rent_merged<-sp::merge(tracts,
                       rent,
                       by.x="AFFGEOID",
                       by.y="GEOID",
                       duplicateGeoms = T)

#######################
#fraction calculation
#######################
rent_lim<-rent %>%
  select(c("GEOID","Year","Amount"))%>%
  rename(Rent_Amount=Amount)

merged_income_rent<-income_detailed %>%
  inner_join(rent_lim, by=c("GEOID","Year")) %>%
  mutate(Proportion_Rent_Income=(Rent_Amount/(Amount/12))) %>%
  mutate(Proportion_Rent_Income=ifelse(Proportion_Rent_Income>1,
                                       1.0,Proportion_Rent_Income)) %>%
  mutate(Proportion_Rent_Income=Proportion_Rent_Income*100)

merged_income_rent<-sp::merge(tracts,
                       merged_income_rent,
                       by.x="AFFGEOID",
                       by.y="GEOID",
                       duplicateGeoms = T)

#########################
#rent burdened population
#########################
burden<-read.csv("Rent_Burden__LA_.csv",header=TRUE)
table(burden$Year)#2010 to 2017
GEOID<-as.data.frame(table(burden$GEOID))

#burden<-burden %>%
  #mutate(Amount=as.numeric(gsub(",","",Amount)))

burden_merged<-sp::merge(tracts,
                       burden,
                       by.x="AFFGEOID",
                       by.y="GEOID",
                       duplicateGeoms = T)

#########################
#Race/Ethinicity
#########################
race<-read.csv("Race___Ethnicity__LA_.csv",header=TRUE)
table(burden$Year)#2010 to 2016
GEOID<-as.data.frame(table(race$GEOID))

#check sum
race_check_sum <-race %>%
  group_by(GEOID,Neighborhood,Tract,Tract.Number,Year)%>%
  summarise(Percent = sum(Percent))

#take max to plot majority race
race_max<-race %>% 
  mutate(Count=as.numeric(Count)) %>% 
  group_by(GEOID,Neighborhood,Tract,Tract.Number,Year) %>% 
  slice(which.max(Percent))

#burden<-burden %>%
#mutate(Amount=as.numeric(gsub(",","",Amount)))
race_max_merged<-sp::merge(tracts,
                         race_max,
                         by.x="AFFGEOID",
                         by.y="GEOID",
                         duplicateGeoms = T)

#########################
#Employment
#########################
employ<-read.csv("Employment__LA_.csv",header=TRUE)
table(employ$Year)#2010 to 2017
GEOID<-as.data.frame(table(employ$GEOID))
table(employ$Variable)

#check sum
employ_check_sum <-employ %>%
  group_by(GEOID,Neighborhood,Tract,Tract.Number,Year)%>%
  summarise(Percent = sum(Percent))

#just keep unemployment rate
unemploy<-employ %>% 
  filter(Variable=="Unemployment Rate")

unemploy_merged<-sp::merge(tracts,
                           unemploy,
                           by.x="AFFGEOID",
                           by.y="GEOID",
                           duplicateGeoms = T)

#########################
#Subsidized Housing
#########################
sub<-read.csv("Subsidized_Housing__LA_.csv",header=TRUE)
table(sub$Year)#2012 to 2017
GEOID<-as.data.frame(table(sub$GEOID))
table(sub$Variable)

#sum total number of units
sub <-sub %>%
  mutate(Count=as.numeric(Count))

sub_totalunits <-sub %>%
  group_by(GEOID,Neighborhood,Tract,Tract.Number,Year)%>%
  summarise(Count = sum(Count))

sub_totalunits_merged<-sp::merge(tracts,
                           sub_totalunits,
                           by.x="AFFGEOID",
                           by.y="GEOID",
                           duplicateGeoms = T)

#########################
#Overcrowding
#########################
over<-read.csv("Overcrowding__LA_.csv",header=TRUE)
table(over$Year)#2010 to 2017
GEOID<-as.data.frame(table(over$GEOID))
table(over$Variable)#Includes only number of overcrowded houses

over_merged<-sp::merge(tracts,
                                 over,
                                 by.x="AFFGEOID",
                                 by.y="GEOID",
                                 duplicateGeoms = T)

#########################
#Housing Stability
#########################
stab<-read.csv("Housing_Stability__LA_.csv",header=TRUE)
table(stab$Year)#2010 to 2017
GEOID<-as.data.frame(table(stab$GEOID))
table(stab$Variable)#Includes only number of stable HHs

stab_merged<-sp::merge(tracts,
                       stab,
                       by.x="AFFGEOID",
                       by.y="GEOID",
                       duplicateGeoms = T)

#####################################
#####################################
#create palattes
#####################################
#####################################
summary(rent_merged$Amount)
summary(income_detailed_merged$Amount)
summary(merged_income_rent$Proportion_Rent_Income)
summary(burden_merged$Percent)
summary(unemploy_merged$Percent)
summary(sub_totalunits_merged$Count)
summary(over_merged$Percent)
summary(stab_merged$Percent)

#rent palatte
pal_rent <- 
  colorNumeric(palette = "magma", 
              domain=c(0,5000))
#income palatte
pal_detail <- 
  colorNumeric(palette = "magma", 
               domain=c(0,300000))
#proportion palatte
pal_prop <- 
  colorNumeric(palette = "magma", 
               domain=c(0,100))
#burden palatte
pal_burden <- 
  colorNumeric(palette = "magma", 
               domain=c(0,100))
#race palatte
pal_race <-
  colorFactor(palette = "magma",
              domain=race_max_merged$Variable)
#unemploy palatte
pal_unemploy <- 
  colorNumeric(palette = "magma", 
               domain=c(0,100))
#sub palatte
pal_sub <- 
  colorQuantile(palette = "magma", 
               domain=sub_totalunits_merged$Count,
               n=4)
#over palatte
pal_over <- 
  colorNumeric(palette = "magma", 
               domain=c(0,100))
#stab palatte
pal_stab <- 
  colorNumeric(palette = "magma", 
               domain=c(0,100))

#####################################
#####################################
#CREATE MAPS
#####################################
#####################################
ui<-shinyUI(fluidPage(titlePanel("Author: Alfonso Berumen, 
                          City of Los Angeles: Data Angels"),
               mainPanel(h1("American Community Survey, 5-year estimates"), 
                         h2("Periods: 2006-10, 
                            2007-11, 
                            2008-12, 
                            2009-13, 
                            2010-14, 
                            2011-15, 
                            2012-16,
                            2013-17"),
                         h3("Census Tract"),
                         tabsetPanel(
                           tabPanel("Rent",leafletOutput("leafmap_rent")), 
                           tabPanel("Income",leafletOutput("leafmap_income")),
                           tabPanel("Proportion: Rent/Income",
                                    leafletOutput("leafmap_prop")),
                           tabPanel("Unemployment Rate",
                                    leafletOutput("leafmap_unemploy")),
                           tabPanel("Proportion: Rent Burdened",
                                    leafletOutput("leafmap_burden")),
                           tabPanel("Proportion: Stable HHs",
                                    leafletOutput("leafmap_stab")),
                           tabPanel("Count: Total Subsidized Units",
                                    leafletOutput("leafmap_sub")),
                           tabPanel("Proportion: Overcrowded",
                                    leafletOutput("leafmap_over")),
                           tabPanel("Race: Majority",
                                    leafletOutput("leafmap_race")))),
               selectInput(inputId = "Year", "Year", 
                           choices = list(2010,
                                          2011,
                                          2012,
                                          2013,
                                          2014,
                                          2015,
                                          2016,
                                          2017)),
               pickerInput("Neighborhood", "Choose a Neighborhood:",
                           choices=levels(unique((rent_merged$Neighborhood))),
                           options = list(`actions-box` = TRUE),
                           multiple = T)
))
server<-function(input, output) {
#rent
  output$leafmap_rent = renderLeaflet({
    rent_subset<-subset(rent_merged,
                          (rent_merged$Year == input$Year)
                          &
                            as.factor(rent_merged$Neighborhood) %in% input$Neighborhood)
    leaflet(rent_subset,width = "100%") %>%
      addPolygons(popup = paste("Neighborhood: ",rent_subset$Neighborhood,"<br>",
                                "Tract: ",rent_subset$Tract,"<br>",
                                "Median Rent ($): ",rent_subset$Amount),
                  stroke = FALSE,
                  smoothFactor = 0,
                  fillOpacity = 0.7,
                  color = ~ pal_rent(rent_subset$Amount),
                  data = rent_subset)%>%
      addProviderTiles(provider = "CartoDB.Positron") %>%
      addLegend("bottomleft", 
                pal = pal_rent, 
                values = ~ rent_subset$Amount,
                title = "Median Rent",
                opacity = 1)
  })
#income
  output$leafmap_income = renderLeaflet({
    income_detailed_subset<-subset(income_detailed_merged,
                                   (income_detailed_merged$Year == input$Year)
                                   &
                                     as.factor(income_detailed_merged$Neighborhood) %in% input$Neighborhood)
    leaflet(income_detailed_subset,width = "100%") %>%
      addPolygons(popup = paste("Neighborhood: ",income_detailed_subset$Neighborhood,"<br>",
                                "Tract: ",income_detailed_subset$Tract,
                                "Median Income ($): ",income_detailed_subset$Amount),
                  stroke = FALSE,
                  smoothFactor = 0,
                  fillOpacity = 0.7,
                  color = ~ pal_detail(Amount),
                  data = income_detailed_subset)%>%
      addProviderTiles(provider = "CartoDB.Positron") %>%
      addLegend("bottomleft", 
                pal = pal_detail, 
                values = ~ Amount,
                title = "Median HH Income",
                opacity = 1)
  })
  #prop
  output$leafmap_prop = renderLeaflet({
    merged_subset<-subset(merged_income_rent,
                                   (merged_income_rent$Year == input$Year)
                                   &
                                     as.factor(merged_income_rent$Neighborhood) %in% input$Neighborhood)
    leaflet(merged_subset,width = "100%") %>%
      addPolygons(popup = paste("Neighborhood: ",merged_subset$Neighborhood,"<br>",
                                "Tract: ",merged_subset$Tract,"<br>",
                                "Proportion (%): ",merged_subset$Proportion_Rent_Income),
                  stroke = FALSE,
                  smoothFactor = 0,
                  fillOpacity = 0.7,
                  color = ~ pal_prop(Proportion_Rent_Income),
                  data = merged_subset)%>%
      addProviderTiles(provider = "CartoDB.Positron") %>%
      addLegend("bottomleft", 
                pal = pal_prop, 
                values = ~ Proportion_Rent_Income,
                title = "Proportion (%) = Median Rent/Median HH Income",
                opacity = 1)
  })
  #unemployment rate
  output$leafmap_unemploy = renderLeaflet({
    unemploy_subset<-subset(unemploy_merged,
                          (unemploy_merged$Year == input$Year)
                          &
                            as.factor(unemploy_merged$Neighborhood) %in% input$Neighborhood)
    leaflet(unemploy_subset,width = "100%") %>%
      addPolygons(popup = paste("Neighborhood: ",unemploy_subset$Neighborhood,"<br>",
                                "Tract: ",unemploy_subset$Tract,"<br>",
                                "Percent (%): ",unemploy_subset$Percent),
                  stroke = FALSE,
                  smoothFactor = 0,
                  fillOpacity = 0.7,
                  color = ~ pal_unemploy(Percent),
                  data = unemploy_subset)%>%
      addProviderTiles(provider = "CartoDB.Positron") %>%
      addLegend("bottomleft", 
                pal = pal_unemploy, 
                values = ~ Percent,
                title = "Unemployment Rate",
                opacity = 1)
  })
  #stable
  output$leafmap_stab = renderLeaflet({
    stab_subset<-subset(stab_merged,
                          (stab_merged$Year == input$Year)
                          &
                            as.factor(stab_merged$Neighborhood) %in% input$Neighborhood)
    leaflet(stab_subset,width = "100%") %>%
      addPolygons(popup = paste("Neighborhood: ",stab_subset$Neighborhood,"<br>",
                                "Tract: ",stab_subset$Tract,"<br>",
                                "Percent (%): ",stab_subset$Percent,"<br>",
                                "Stable HHs: ",stab_subset$Count,"<br>",
                                "Total HHs: ",stab_subset$Denominator,"<br>"),
                  stroke = FALSE,
                  smoothFactor = 0,
                  fillOpacity = 0.7,
                  color = ~ pal_stab(Percent),
                  data = stab_subset)%>%
      addProviderTiles(provider = "CartoDB.Positron") %>%
      addLegend("bottomleft", 
                pal = pal_stab, 
                values = ~ Percent,
                title = "Percent of HHs Stable",
                opacity = 1)
  })
  #burden
  output$leafmap_burden = renderLeaflet({
    burden_subset<-subset(burden_merged,
                          (burden_merged$Year == input$Year)
                          &
                            as.factor(burden_merged$Neighborhood) %in% input$Neighborhood)
    leaflet(burden_subset,width = "100%") %>%
      addPolygons(popup = paste("Neighborhood: ",burden_subset$Neighborhood,"<br>",
                                "Tract: ",burden_subset$Tract,"<br>",
                                "Percent (%): ",burden_subset$Percent,"<br>",
                                "Burdened HHs: ",burden_subset$Count,"<br>",
                                "Total HHs: ",burden_subset$Denominator,"<br>"),
                  stroke = FALSE,
                  smoothFactor = 0,
                  fillOpacity = 0.7,
                  color = ~ pal_burden(Percent),
                  data = burden_subset)%>%
      addProviderTiles(provider = "CartoDB.Positron") %>%
      addLegend("bottomleft", 
                pal = pal_burden, 
                values = ~ Percent,
                title = "Percent of Renters Paying > 30% of Income",
                opacity = 1)
  })
  #subsidized housing
  output$leafmap_sub = renderLeaflet({
    sub_subset<-subset(sub_totalunits_merged,
                        (sub_totalunits_merged$Year == input$Year)
                        &
                          as.factor(sub_totalunits_merged$Neighborhood) %in% input$Neighborhood)
    leaflet(sub_subset,width = "100%") %>%
      addPolygons(popup = paste("Neighborhood: ",sub_subset$Neighborhood,"<br>",
                                "Tract: ",sub_subset$Tract,"<br>",
                                "Units: ",sub_subset$Count),
                  stroke = FALSE,
                  smoothFactor = 0,
                  fillOpacity = 0.7,
                  color = ~ pal_sub(Count),
                  data = sub_subset)%>%
      addProviderTiles(provider = "CartoDB.Positron") %>%
      addLegend("bottomleft", 
                pal = pal_sub, 
                values = ~ Count,
                title = "Total Units: Quartile",
                opacity = 1)
  })
  #over
  output$leafmap_over = renderLeaflet({
    over_subset<-subset(over_merged,
                          (over_merged$Year == input$Year)
                          &
                            as.factor(over_merged$Neighborhood) %in% input$Neighborhood)
    leaflet(over_subset,width = "100%") %>%
      addPolygons(popup = paste("Neighborhood: ",over_subset$Neighborhood,"<br>",
                                "Tract: ",over_subset$Tract,"<br>",
                                "Percent (%): ",over_subset$Percent,"<br>",
                                "Overcrowded HHs: ",over_subset$Count,"<br>",
                                "Total HHs: ",over_subset$Denominator,"<br>"),
                  stroke = FALSE,
                  smoothFactor = 0,
                  fillOpacity = 0.7,
                  color = ~ pal_over(Percent),
                  data = over_subset)%>%
      addProviderTiles(provider = "CartoDB.Positron") %>%
      addLegend("bottomleft", 
                pal = pal_over, 
                values = ~ Percent,
                title = "Percent of HHs Overcrowded",
                opacity = 1)
  })
#race
  output$leafmap_race = renderLeaflet({
    race_subset<-subset(race_max_merged,
                          (race_max_merged$Year == input$Year)
                          &
                            as.factor(race_max_merged$Neighborhood) %in% input$Neighborhood)
    leaflet(race_subset,width = "100%") %>%
      addPolygons(popup = paste("Neighborhood: ",race_subset$Neighborhood,"<br>",
                                "Tract: ",race_subset$Tract,"<br>",
                                "Percent (%): ",race_subset$Percent,"<br>",
                                "HHs: ",race_subset$Count),
                  stroke = FALSE,
                  smoothFactor = 0,
                  fillOpacity = 0.7,
                  color = ~ pal_race(Variable),
                  data = race_subset)%>%
      addProviderTiles(provider = "CartoDB.Positron") %>%
      addLegend("bottomleft", 
                pal = pal_race, 
                values = ~ Variable,
                title = "Majority Race",
                opacity = 1)
  })
}
shinyApp(ui,server)

#check<-data.frame(table(rent_merged$Neighborhood))
#check2<-data.frame(table(income_detailed_merged$Neighborhood))
#check3<-data.frame(table(burden$Neighborhood))