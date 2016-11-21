#### Create choropleth maps of initial 2016 prez election results ####

# Load libraries
library(choroplethr)
library(choroplethrMaps)
library(ggplot2)
library(RColorBrewer)

# One source of initial data scrapes townhall.com using Python
# Check update time stamp to see how recently it was updated
prez = read.csv("https://raw.githubusercontent.com/tonmcg/2016_County_Level_Election_Results/master/2016_US_County_Level_Presidential_Results.csv", header=T, stringsAsFactors = F)

# Another source is here: http://data.opendatasoft.com/explore/dataset/usa-2016-presidential-election-by-county@public/

# Make data frame for percent who voted GOP
gop = data.frame(region = prez$combined_fips, value = prez$per_gop)

# Basic map
county_choropleth(gop, title = "Trump Voting Support - 2016 Presidental Election", legend = "Percent\n(Natural Breaks)", num_colors = 5)

# Map as object to allow custom colors
# Create choropleth object
gop_map = CountyChoropleth$new(gop)
# Add title
gop_map$title = "Trump Voting Support - 2016 Presidental Election"
# Add legend title, use Red-Blue palette, drop=FALSE to keep color levels, direction=-1 to reverse the Red/Blue direction
gop_map$ggplot_scale = scale_fill_brewer(name="Percent\n(Natural Breaks)", palette="RdBu", drop=FALSE, direction=-1)
# Show map
gop_map$render()
