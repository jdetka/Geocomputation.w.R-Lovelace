#### CH. 3 - Attribute Data Operations ####
#### ipackitup - My Package Loading Script ####

# My little custom script to check, upload, install, and confirm relevant libraries and packages #
ipakitup <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}
packages <- c('sf', 'raster', 'spData', 'dplyr', 'stringr', 'tidyr', 
              devtools::install_github("Nowosad/spDataLarge", force = FALSE)) # packages / libraries to install. 
ipakitup(packages) # RUns the function on 'packages

# Also install Larger geographic dataset. 
# devtools::install_github("Nowosad/spDataLarge")

rm(list = ls())

# Check out the world dataset attributes. 

dim(world); 
# Can also be achieved with 
nrow(world); ncol(world)


# Subsetting 
world_df = st_drop_geometry(world); world_df # Ditch the geom attribute. 

world[1:6, ] # subset rows by position
world[, 1:3] # subset columns by position
world[, c("name_long", "lifeExp")] # subset columns by name

# Subset by small country size.
small_countries = world[world$area_km2 < 10000, ]
small_countries = subset(world, area_km2 < 10000)

plot(small_countries["continent"]) # :-) Tiny

# Example dplyr approach
world1 = dplyr::select(world, name_long, pop)
plot(world1["pop"])

world4 = dplyr::select(world, name_long, population = pop) # Subsetting and renaming
world4


# I like pipes.
world7 = world %>%
  filter(continent == "Asia") %>%
  dplyr::select(name_long, continent) %>%
  slice(1:5)

# Alternative without pipes would be nested functions. 
world8 = slice(
  dplyr::select(
    filter(world, continent == "Asia"),
    name_long, continent),
  1:5)

# Aggregation is Awesome! summarize datasets by a ‘grouping variable’

# Non-spatial version
world_agg1 = aggregate(pop ~ continent, FUN = sum, data = world, na.rm = TRUE); class(world_agg1)

# Spatial version
world_agg2 = aggregate(world["pop"], by = list(world$continent), FUN = sum, na.rm = TRUE)
plot(world_agg2)

# dplyr's summarize() function is analogous to aggregate(). Here with pipes
world_agg3 = world %>%
  group_by(continent) %>%
  summarize(pop = sum(pop, na.rm = TRUE)); world_agg3

world %>% 
  summarize(pop = sum(pop, na.rm = TRUE), n = n())

# Example of chaining with pipes and select(), summarize(), group_by(), top_n() 
world %>% 
  dplyr::select(pop, continent) %>% 
  group_by(continent) %>% 
  summarize(pop = sum(pop, na.rm = TRUE), n_countries = n()) %>% 
  top_n(n = 3, wt = pop) %>%
  arrange(desc(pop)) %>%
  st_drop_geometry()

# Left-join \
world_coffee = left_join(world, coffee_data, by = "name_long")
world_coffee

# View all the approaches for vector attribute manipulation
methods(class = "sf") # methods for sf objects, first 12 shown

# 3.3 Manipulating Raster Objects

elev = raster(nrows = 6, ncols = 6, res = 0.5,
              xmn = -1.5, xmx = 1.5, ymn = -1.5, ymx = 1.5,
              vals = 1:36)

plot(elev)

grain_order = c("clay", "silt", "sand")
grain_char = sample(grain_order, 36, replace = TRUE)
grain_fact = factor(grain_char, levels = grain_order)
grain = raster(nrows = 6, ncols = 6, res = 0.5, 
               xmn = -1.5, xmx = 1.5, ymn = -1.5, ymx = 1.5,
               vals = grain_fact)

plot(grain)

# Add a new column with soil moisture
levels(grain)[[1]] = cbind(levels(grain)[[1]], wetness = c("wet", "moist", "dry"))
levels(grain)

# returns the grain size and wetness of cell IDs 1, 11 and 35:
factorValues(grain, grain[c(1, 11, 35)])

r_stack = stack(elev, grain)
names(r_stack) = c("elev", "grain")
# three ways to extract a layer of a stack
raster::subset(r_stack, "elev")
r_stack[["elev"]]
r_stack$elev

# Overwritting a value
elev[1, 1] = 0
elev[]
elev[1, 1:2] = 0
 
# Get stats on raster
cellStats(elev, sd)
summary(brick(elev, grain)) # Or summarize  a whole brick
hist(elev)

#### Ch. 3 Exercises ####

data(us_states)
data(us_states_df)

# Create a new object called us_states_name that contains only the NAME column from the us_states object. 
# What is the class of the new object and what makes it geographic?
us_states_name <- st_drop_geometry(us_states[,2]) 
us_states_name

# Select columns from the us_states object which contain population data. 
# Obtain the same result using a different command 
# (bonus: try to find three ways of obtaining the same result). 
# Hint: try to use helper functions, such as contains or starts_with from dplyr (see ?contains).
us_states_subset <- us_states[us_states$total_pop_10 != "NA", ]
us_states_subset <- subset(us_states, total_pop_10 != "NA")

# I like pipes.
us_states_subset = us_states %>%
  filter(total_pop_10 & total_pop_15 != "NA") %>% 
  select(1:6)
us_states_subset
names(us_states_subset)

# Find all states with the following characteristics (bonus find and plot them):
  # Belong to the Midwest region.
us_states_midwest = us_states %>%
  filter(REGION == "Midwest") %>% 
  select(1:6)
plot(us_states_midwest["total_pop_15"])

  # Belong to the West region, 
  # have an area below 250,000 km2 
  # 2015 a population greater than 5,000,000 residents 
  # (hint: you may need to use the function units::set_units() or as.numeric()).
  
us_states_west = us_states            %>%
  filter(REGION == "West")            %>% 
  filter(as.numeric(AREA) <= 250000)  %>%
  filter(as.numeric(total_pop_15) <= 5000000) %>%
  select(1:6)

us_states_west
plot(us_states_west["AREA"])
  

# Belong to the South region, had an area larger than 150,000 km2 or a total population in 2015 larger than 7,000,000 residents.









