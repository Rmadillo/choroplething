#### Create choropleth maps of initial 2016 prez election results ####

# Load libraries
library(choroplethr)
library(choroplethrMaps)
library(ggplot2)
library(RColorBrewer)
library(sp)
library(tigris)
library(leaflet)
library(scales)


#### Data ####

# One source of initial data scrapes townhall.com using Python
# Check update time stamp to see how recently it was updated
prez = read.csv("https://raw.githubusercontent.com/tonmcg/2016_County_Level_Election_Results/master/2016_US_County_Level_Presidential_Results.csv", header=T, stringsAsFactors = F)

# Another source is here: http://data.opendatasoft.com/explore/dataset/usa-2016-presidential-election-by-county@public/

# FIPS code into character for use with Tiger data
prez$GEOID = formatC(prez$combined_fips, width = 5, format = "d", flag = "0")

# Round percentages to 2 decimal places
prez$per_dem = round(prez$per_dem, 2)
prez$per_gop = round(prez$per_gop, 2)


#### Choropleth ####

# Percent GOP votes, FIPS code using numeric for use with choroplether
gop = data.frame(region = prez$combined_fips, value = prez$per_gop)

# Basic choroplether map
county_choropleth(gop, title = "Trump Voting Support - 2016 Presidental Election",
                  legend = "Percent\n(Natural Breaks)", num_colors = 5)

# As choroplether object to allow custom colors
gop_map = CountyChoropleth$new(gop)
gop_map$title = "Trump Voting Support - 2016 Presidental Election"
gop_map$ggplot_scale = scale_fill_brewer(name="Percent\n(Natural Breaks)", palette="RdBu", drop=FALSE, direction=-1)
gop_map$render()


#### Leaflet for interactive map ####
# Modified from https://www.datascienceriot.com/mapping-us-counties-in-r-with-fips/kris/

# Get counties from US Census Tiger files
us.map = counties(cb = TRUE, resolution = '20m')

# Remove Alaska(2), Hawaii(15), Puerto Rico (72), Guam (66), Virgin Islands (78), American Samoa (60)
# Mariana Islands (69), Micronesia (64), Marshall Islands (68), Palau (70), Minor Islands (74)
us.map = us.map[!us.map$STATEFP %in% c("02", "15", "72", "66", "78", "60", "69",
                                        "64", "68", "70", "74"),]

# Make sure other outling islands are removed.
us.map = us.map[!us.map$STATEFP %in% c("81", "84", "86", "87", "89", "71", "76",
                                        "95", "79"),]

# Merge counties shapefile with prez data
leafmap = merge(us.map, prez, by=c("GEOID"))

# Format popup data for leaflet map.
popup_dat = paste0("<strong>County: </strong>", 
                    leafmap$county_name, ", ", leafmap$state_abbr, 
                    "<br><strong>Percent Clinton: </strong>", 
                    leafmap$per_dem,
                    "<br><strong>Percent Drumpf: </strong>", 
                    leafmap$per_gop,
                    "<br><strong>Percent Difference: </strong>", 
                    leafmap$per_point_diff,
                    "<br><strong>Total Votes: </strong>", 
                    leafmap$total_votes,
                    "<br><strong>Votes Difference: </strong>", 
                    leafmap$diff)

# Make a Red-Blue palette with 20 breaks
pal1 = colorQuantile("RdBu", NULL, n = 20)

# Render final map in leaflet.
leaflet(data = leafmap) %>% 
  addTiles() %>%
  addPolygons(fillColor = ~pal1(per_dem), 
                fillOpacity = 0.8, 
                color = "#BDBDC3", 
                weight = 1,
                popup = popup_dat)


# Use a 5 value palatte
pa2 = colorQuantile("RdBu", NULL, n = 5)

# Render final map in leaflet, add legend
leaflet(data = leafmap) %>% 
  addTiles() %>%
  addPolygons(fillColor = ~pa2(per_dem), 
                fillOpacity = 0.8, 
                color = "#BDBDC3", 
                weight = 1,
                popup = popup_dat) %>% 
  addLegend(pal = pal, 
            values = leafmap$per_dem, 
            position = "bottomright", 
            title = "Percent Clinton Vote")


#### Save to self contained html ####

# Put map in object
m = leaflet(data = leafmap) %>% 
  addTiles() %>%
  addPolygons(fillColor = ~pal1(per_dem), 
                fillOpacity = 0.8, 
                color = "#BDBDC3", 
                weight = 1,
                popup = popup_dat)

# Dimension of the map, change depending on screen width
m$width = 1000
m$height = 800

# Export as HTML file
htmlwidgets::saveWidget(m, "election_map.html", selfcontained = TRUE)

# End of file
