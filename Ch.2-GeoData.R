


#### CH. 2 - Geographic Data with R ####
#### ipackitup - My Package Loading Script ####
# My little custom script to check, upload, install, and confirm relevant libraries and packages #
ipakitup <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}
packages <- c('sf', 'raster', 'spData') # packages / libraries to install. 
ipakitup(packages) # RUns the function on 'packages

# Also install Larger geographic dataset. 
devtools::install_github("Nowosad/spDataLarge")

# Check out the really well documented vignettes
vignette(package = "sf") # see list of available vignettes 
vignette("sf1")          # an introduction to the package

names(world) # Check out header names in world dataset from http://nowosad.github.io/spData
plot(world)  # A spatial plot of the world using the sf package, with a facet for each attribute.
plot(world[3:6])
plot(world["pop"])

summary(world["lifeExp"])
summary(world["pop"])

world_mini <- world[1:4, 1:7]
world_mini
View(world_mini)

world_sp <- as(world, Class = "Spatial")
world_sf = st_as_sf(world_sp)

#Subset world map to only asia. 
world_asia = world[world$continent == "Asia", ]
asia = st_union(world_asia)
asia
plot(asia)

# North America
world_north_amer = world[world$continent == "North America", ]
north_amer = st_union(world_north_amer)
north_amer
plot(north_amer)

plot(world["pop"], reset = FALSE)
plot(asia, add = TRUE, col = "red")
plot(north_amer, add = TRUE, col = 'lightgreen')

# Base plot arguments 
plot(world["continent"], reset = FALSE)
cex = sqrt(world$pop) / 10000  
world_cents = st_centroid(world, of_largest = TRUE) # st_centroid() to convert one geometry type (polygons) to another (points)
plot(st_geometry(world_cents), add = TRUE, cex = cex)

india = world[world$name_long == "India", ]
plot(st_geometry(india), expandBB = c(0, 0.2, 0.1, 1), col = "gray", lwd = 3)
plot(world_asia[0], add = TRUE)

linestring_matrix <- st_linestring(rbind(c(1, 5), c(4, 4), c(4, 1), c(2, 2), c(3, 2)))
plot(linestring_matrix)

#### 2.2.8 The sf class ####
# temperature of 25°C in London on June 21st, 2017

lnd_point = st_point(c(0.1, 51.5))                 # sfg object
lnd_geom = st_sfc(lnd_point, crs = 4326)           # sfc object
lnd_attrib = data.frame(                           # data.frame object
  name = "London",
  temperature = 25,
  date = as.Date("2017-06-21")
)
lnd_sf = st_sf(lnd_attrib, geometry = lnd_geom)    # sf object
class(lnd_sf)

# 1. coordinates were used to create the simple feature geometry (sfg). 
# 2. geometry was converted into a simple feature geometry column (sfc), with a CRS. 
# 3. attributes were stored in a data.frame, which was combined with the sfc object with st_sf(). 
# This results in an sf object, as demonstrated below (some output is ommited):

plot(lnd_point)
View(lnd_sf)


#### 2.3 Raster data ####
vignette("functions", package = "raster")


raster_filepath = system.file("raster/srtm.tif", package = "spDataLarge")
new_raster = raster(raster_filepath); new_raster
plot(new_raster)

dim(new_raster)
ncell(new_raster)
extent(new_raster)
inMemory(new_raster)
help("raster-package")


# Which drivers are available on my computer? A lot!!
# 'Geospatial' Data Abstraction Library ('GDAL')
raster::writeFormats()
rgdal::gdalDrivers()

# Make a raster from scratch. 
new_raster2 = raster(nrows = 6, ncols = 6, res = 0.5, 
                     xmn = -1.5, xmx = 1.5, ymn = -1.5, ymx = 1.5,
                     vals = 1:36)
plot(new_raster2)
# More tips on creating rasters ?raster

# Raster brick
multi_raster_file = system.file("raster/landsat.tif", package = "spDataLarge")
r_brick = brick(multi_raster_file)
plot(r_brick); nlayers(r_brick); r_brick

# RasterStack allows you to connect several raster objects stored in different files or 
# multiple objects in memory. More specifically, a RasterStack is a list of RasterLayer 
# objects with the same extent and resolution. 

raster_on_disk = raster(r_brick, layer = 1)
raster_in_memory = raster(xmn = 301905, xmx = 335745,
                          ymn = 4111245, ymx = 4154085, 
                          res = 30)
values(raster_in_memory) = sample(seq_len(ncell(raster_in_memory)))
crs(raster_in_memory) = crs(raster_on_disk)

r_stack = stack(raster_in_memory, raster_on_disk)
r_stack

plot(r_stack)

#### 2.4 Coordinate Reference Systems ####

st_proj_info(type = "datum") # Available datums

st_proj_info(type = "proj") # Available projections 
# conic (mid-lat), cylindrical (global), and planar (polar).


