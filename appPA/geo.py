#### from github copilot:
# Mapping census tracts to town names
# You said: map census tracts to town names
# map census tracts to town names
# Copilot said: Mapping census tracts to town names typically
# Mapping census tracts to town names typically involves using geographic boundary data, such as shapefiles or GeoJSONs, provided by the U.S. Census Bureau (TIGER/Line), plus a lookup table matching census tract codes to towns (municipalities). The actual mapping can depend on your area of interest (state, county, etc.).
# 
# General Steps
# Get Census Tract Data: Download TIGER/Line shapefiles for census tracts for your state/county from the Census Bureau.
# 
# Get Town/Municipality Boundaries: Also get TIGER/Line shapefiles for places ("places" in Census terms include towns, cities, and some villages).
# 
# Spatial Join: Use GIS software (QGIS, ArcGIS) or Python (GeoPandas) to map each tract to the town (if any) that contains its centroid. Not all tracts will fit perfectly; some may span several towns.
# 


import numpy as numpy
import geopandas as gpd


states = gpd.read_file("tl_2025_us_state/tl_2025_us_state.shp")

# Load census tracts and towns shapefiles
tracts = gpd.read_file("tl_2020_25_tract.shp")     # Massachusetts tracts example
towns = gpd.read_file("tl_2020_25_place.shp")      # Massachusetts places

# Reproject if needed so both are in the same CRS
tracts = tracts.to_crs(towns.crs)

# Get tract centroids for mapping
tracts['centroid'] = tracts.geometry.centroid
tracts_centroiids = tracts.set_geometry('centroid')

# Spatial join: map each tract centroid to town polygon
tracts_with_town = gpd.sjoin(tracts_centroids, towns, how='left', op='within')

# Output tract-to-town mapping
tract_to_town = tracts_with_town[['GEOID', 'NAME_left', 'NAME_right']]
tract_to_town.rename(columns={'NAME_right': 'Town_Name', 'GEOID': 'Tract'}, inplace=True)
print(tract_to_town)
