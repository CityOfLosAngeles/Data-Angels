setwd("C:/Users/marin/Desktop/Data Angels")

library(RCurl)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(pals)
library(colorRamps)
library(gridExtra)
library(scales)

url <- "https://raw.githubusercontent.com/CityOfLosAngeles/Data-Angels/master/Fall%202018%20Projects/LA_Outmigration/Data/ipums_clean.csv"

#download.file(url, "ipums_clean.csv", method="curl")

#full description of the data here https://github.com/CityOfLosAngeles/Data-Angels/tree/master/Fall%202018%20Projects/LA_Outmigration/Data

data <- read.csv("ipums_clean.csv")
data$YEAR <- as.factor(data$YEAR)


########################################### BY AGE ###############################################################


by_age <- data %>% 
                group_by(YEAR, AGE) %>%
                          summarise (No_movers = sum(PERWT))

plot_age <- ggplot(by_age, aes(AGE, No_movers, color = YEAR)) + geom_line() + scale_color_brewer(palette="Paired") +
            scale_x_continuous(breaks=seq(0,100,10)) + ggtitle("LA Outmigration by Age") +
            ylab("Number of movers")+
            theme(panel.background = element_blank(),
                axis.line = element_line(colour = "black"), 
                panel.grid.major.y = element_line(colour="grey"))
png("LA_Outmigration_by_AGE.png", width = 1698, height = 1056, res = 180)
plot_age
dev.off()



#splitting data into age groups (groups defined by census)
Age.Group.Description <- c("Age.1_4", "Age.5_17", "Age.18_19", "Age.20_24", "Age.25_29", "Age.30_34", "Age.35_39",
                           "Age.40_44", "Age.45_49", "Age.50_54", "Age.55_59", "Age.60_64", "Age.65_69", "Age.70_74",
                           "Age.75_and_over")
data$AGE.GROUP<-cut(data$AGE, c(0,4,17,19,24,29,34, 39, 44, 49, 54, 59, 64, 69, 74,100), Age.Group.Description)
by_age_group <- data %>% 
                    group_by(YEAR, AGE.GROUP) %>%
                          summarise (No_movers = sum(PERWT))

#plot by age groups (x axis), years in color 
plot_age_group <- ggplot(by_age_group, aes(AGE.GROUP, No_movers,group = YEAR, color = YEAR)) + 
                    geom_line() +
                    ggtitle("LA Outmigration by Age")+ 
                    scale_color_brewer(palette="Paired") +
                    theme(axis.text.x = element_text(angle = 90, hjust = 1),
                                  panel.background = element_blank(),
                                  axis.line = element_line(colour = "black"), 
                                  panel.grid.major.y = element_line(colour="grey")) 
plot_age_group

#by year, age in color
plot_age <- ggplot(by_age_group, aes(YEAR, No_movers,group = AGE.GROUP, color = AGE.GROUP)) + 
  geom_line() +
  ggtitle("LA Outmigration by Age")+ 
  scale_color_manual(values = getPalette(colourCount)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),panel.background = element_blank(),
        axis.line = element_line(colour = "black"), panel.grid.major.y = element_line(colour="grey"))
plot_age


########################################### BY SEX ###############################################################

#by sex
by_sex <- data %>% 
  group_by(YEAR, SEX) %>%
  summarise (No_movers = sum(PERWT))

plot_by_sex <- ggplot(by_sex,aes(x = YEAR, y = No_movers,fill = SEX)) + 
                  geom_bar(position = "fill",stat = "identity") + 
                  theme(panel.background = element_blank(),
                        axis.text.x = element_text(angle = 0, hjust = 0.5))+
                  ggtitle("LA Outmigration by Sex")+
                  ylab("Percentage of movers")+
                  scale_y_continuous(labels = scales::percent)

png("LA_Outmigration_by_SEX.png", width = 1698, height = 1056, res = 180)
plot_by_sex
dev.off()

##############################BY Maritial status#######################################################


by_marst <- data %>% 
  group_by(YEAR, MARST) %>%
  summarise (No_movers = sum(PERWT))

plot_marst <- ggplot(by_marst, aes(YEAR, No_movers,group = MARST, color = MARST)) + 
            geom_line(size=0.7) +
            ggtitle("LA Outmigration by Marital Status")+ 
            scale_color_brewer(palette="Paired") +
            theme(axis.text.x = element_text(angle = 0, hjust = 0.5),panel.background = element_blank(),
            axis.line = element_line(colour = "black"), panel.grid.major.y = element_line(colour="grey"))+
            scale_y_continuous(labels = comma)

png("LA_Outmigration_by_MARST.png", width = 1698, height = 1056, res = 180)
plot_marst
dev.off()

 
by_marst_06_17 <- by_marst[by_marst$YEAR == 2006 | by_marst$YEAR == 2017, ] 
by_marst_06_17$perc <-  by_marst_06_17$No_movers[by_marst_06_17$YEAR == 2006]/sum(by_marst_06_17$No_movers[by_marst_06_17$YEAR == 2006])
by_marst_06_17$perc[by_marst_06_17$YEAR == 2006] <- by_marst_06_17$No_movers[by_marst_06_17$YEAR == 2017]/sum(by_marst_06_17$No_movers[by_marst_06_17$YEAR == 2017])

pie_marst <- ggplot(by_marst_06_17, aes(x="", y=No_movers, fill=MARST))+
              geom_bar(width = 1, stat = "identity", position = "fill") + coord_polar("y", start=0)+
              ggtitle("LA Outmigration by Marital Status for years 2006 and 2017")+ 
              ylab("Percentage of movers") +
              facet_grid(cols = vars(YEAR)) + 
              theme(axis.title.y=element_blank(),
                    axis.line = element_blank(),
                    axis.text = element_blank(),
                    axis.ticks = element_blank()) 
pie_marst


##############################BY RACE#######################################################

by_race <- data %>% 
  group_by(YEAR, RACE) %>%
  summarise (No_movers = sum(PERWT))

plot_race <- ggplot(by_race, aes(YEAR, No_movers,group = RACE, color = RACE)) + 
  geom_line() +
  ggtitle("LA Outmigration by Race")+ 
  scale_color_brewer(palette="Dark2") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),panel.background = element_blank(),
        axis.line = element_line(colour = "black"), panel.grid.major.y = element_line(colour="grey"))+
  scale_y_continuous(labels = comma)
plot_race




############################### INDIVIDUAL RENTERS #######################################

#selecting the rows with no additional family income and filtering out missing values and zero rent rows
ind_rent <- data[data$FTOTINC<=data$INCTOT & data$INCTOT!=9999999 & data$RENT!=0,]

#plotting individual income renters by gender
by_sex <- ind_rent %>% 
  group_by(YEAR, SEX) %>%
  summarise (No_movers = sum(PERWT))

plot_by_sex <- ggplot(by_sex,aes(x = YEAR, y = No_movers,fill = SEX)) + 
  geom_bar(position = "fill",stat = "identity") + 
  theme(panel.background = element_blank(),
        axis.text.x = element_text(angle = 0, hjust = 0.5))+
  ggtitle("LA Outmigrators (Individual Income) by Sex")+
  ylab("Percentage of movers")+
  scale_y_continuous(labels = scales::percent)

png("LA_Outmigration_individual_by_SEX.png", width = 1698, height = 1056, res = 180)
plot_by_sex
dev.off()

#plotting individual income renters by race 

#summarizing information about the residents by race
la_residents <- read.csv("ipums_la_residents.csv")

by_race_residents <- la_residents %>% 
  group_by(YEAR, RACE) %>%
  summarise (No_residents = sum(PERWT))

by_race_out <- data %>% 
  group_by(YEAR, RACE) %>%
  summarise (No_movers = sum(PERWT))

by_race <- merge(by_race_residents, by_race_out, by = c("YEAR", "RACE"))
by_race$perc_out <- round(by_race$No_movers/(by_race$No_residents+by_race$No_movers)*100,2)
by_race$YEAR <- as.factor(by_race$YEAR)
by_race <- by_race[by_race$RACE!="Other",]

plot_race <- ggplot(by_race, aes(YEAR, perc_out,group = RACE, color = RACE)) + 
  geom_line(size=0.6) +
  ggtitle("LA Outmigrators (Individual Income) by Race")+ 
  ylab("Percentage of residents by race") +
  scale_color_brewer(palette="Paired") +
  theme(axis.text.x = element_text(angle = 0, hjust = 0.5),panel.background = element_blank(),
        axis.line = element_line(colour = "black"), panel.grid.major.y = element_line(colour="grey"))+
  scale_y_continuous(labels = comma)

png("LA_Outmigration_individual_by_RACE.png", width = 1698, height = 1056, res = 180)
plot_race
dev.off()

#plotting marital status of individual renters
by_marst <- ind_rent %>% 
  group_by(YEAR, MARST) %>%
  summarise (No_movers = sum(PERWT))

plot_marst <- ggplot(by_marst, aes(YEAR, No_movers,group = MARST, color = MARST)) + 
  geom_line(size=0.7) +
  ggtitle("LA Outmigrators (Individual Income) by Marital Status")+ 
  scale_color_brewer(palette="Paired") +
  theme(axis.text.x = element_text(angle = 0, hjust = 0.5),panel.background = element_blank(),
        axis.line = element_line(colour = "black"), panel.grid.major.y = element_line(colour="grey"))+
  scale_y_continuous(labels = comma)

png("LA_Outmigration_individual_by_MARST.png", width = 1698, height = 1056, res = 180)
plot_marst
dev.off()

#plotting age of individual renters 
by_age <- ind_rent %>% 
  group_by(YEAR, AGE) %>%
  summarise (No_movers = sum(PERWT))

plot_age <- ggplot(by_age, aes(AGE, No_movers, color = YEAR)) + geom_line() + scale_color_brewer(palette="Paired") +
  scale_x_continuous(breaks=seq(0,100,10)) + 
  ggtitle("LA Outmigrators (Individual Income) by Age") +
  ylab("Number of movers")+
  theme(panel.background = element_blank(),
        axis.line = element_line(colour = "black"), 
        panel.grid.major.y = element_line(colour="grey"))
png("LA_Outmigration_individual_by_AGE.png", width = 1698, height = 1056, res = 180)
plot_age
dev.off()
