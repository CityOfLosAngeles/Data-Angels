
## Code 
This project was built to help aide LA City officials gauge the movement of Covid-19 cases throughout the City of Los Angeles with respect to points of interest. It is built with limited local machine intervention: in this case Google Drive and Colab are the main platforms used to run the code. A user need only have a google account to run this model locally.

## Data
Data is pulled from three main sources:
1) Files includes LA focused data csv and json files data sample from the Safefraph dataset. For full access and current data, visit SafeGraph's site [SafeGraph](https://catalog.safegraph.io/app/browse)
2) Daily covid-19 cases throughout Los Angeles are pulled from the [LA Public Health](http://publichealth.lacounty.gov/media/Coronavirus/locations.htm) website. Previous daily snapshots can be found in the Kaggle dataset I created and maintain [here](https://www.kaggle.com/frank122/la-public-health-covid19-cases-point-of-interest), and the Python to web scrape this can be found [here](https://github.com/francisco-avalos/LA_covid19_data_cases).
3) LA zip code data is also web scraped in the process from the [LA Almanac](http://www.laalmanac.com/communications/cm02_communities.php).
