# Install needed packages if not already installed
if (!requireNamespace("tigris")) install.packages("tigris")
if (!requireNamespace("sf")) install.packages("sf")
if (!requireNamespace("dplyr")) install.packages("dplyr")

library(tigris)
library(sf)
library(dplyr)

options(tigris_use_cache = TRUE)

# Download Pennsylvania census tracts
pa_tracts <- tracts(state = "PA", year = 2020, class = "sf")

# Download Pennsylvania towns/places (cities, boroughs, etc.)
pa_places <- places(state = "PA", year = 2020, class = "sf")

# Spatial join: assign each tract to the town it intersects most with
tracts_with_towns <- st_join(pa_tracts, pa_places, join = st_intersects, largest = TRUE)

# Select mapping of tract GEOID to town NAME
mapping <- tracts_with_towns %>%
  select(TRACT_GEOID = GEOID, TOWN_NAME = NAME) %>%
  distinct()

# View mapping
print(mapping)
