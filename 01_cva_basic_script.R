##### Forest Volume Assesment for Douglas Fir and Lodgepole Pine in southwestern Montana (USA)
#Code accompanying Document (Master's Thesis: Development of an applied UAV-SFM Workflow for the Timber Volume Assessment of Coniferous Expansion in southwestern Montana)
#Author: Samuel Schilling, Zurich University of Applied Sciences, samuel.schilling@outlook.com
#Version Date: 03.02.2023
#Version: 1.0.0

#Description: This code detects trees in a pointcloud (using a lmf) and calculates the corresponding diameter at breast height (DBH) for every tree as well as predicts the timber volume on a defined study area. 
#This script is made to validate measurements on stand level. Field data (Cruising data, according to the Forest Service Handbook [Point Sampling]) is required.  
#The default is set for the assessment of Douglas fir stands, if Lodgepole pine shall be analyzed, the Douglas fir lines can be commented out and the Lodgepole lines can be anabled (Tree Detection, Segmentation, DBH-PRediction, and Volume Calculation)


##### Preparation
#Garbage collection to free RAM
gc()

#Load all nescessary libraries
library("lidR")
library(terra)
library(rayshader)
library(geometry)
library(sf)
library(raster)
library(flexclust)
library(tidyverse)
library(dplyr)
library(deldir)
library(magrittr)
library(tidyverse)
library(lubridate)
library(tidyr)
library(readr)
library(ggplot2)
library(gstat)
library(MASS)
library (car)
library(nlstools)
library("vegan")
library(remotes)
library(RMCC)
library(RCSF)


##### Load Data
#Load limits of study area as shapefile
border<-st_read("C:/Users/schilsam/OneDrive - ZHAW/Sam/TreeDetection/Perimeter_Lake_Canyon.shp")

#Load pointcloud (as LAS-file)
pc = readLAS("C:/Users/schilsam/OneDrive - ZHAW/Sam/TreeDetection/Lake_Canyon_Pointcloud.las")

#Load cruising data to dataframe (as CSV-file)
trees_BLM <- read_delim("C:/Users/schilsam/OneDrive - ZHAW/Sam/TreeDetection/Cruising_Data_Lake_Canyon_checked.CSV")

##### Transform Coordinates
border = st_transform(border, st_crs(pc))


##### Preparation of Point Cloud
#Classify Ground Points
las_csf <- classify_ground(pc, algorithm = csf())

#DTM generation
dtm_tin = rasterize_terrain(las_csf, algorithm = tin())

#Normalize Pointcloud
npc <- pc - dtm_tin


#CHM generation
chm <- rasterize_canopy(npc, res = 0.1, algorithm = p2r(subcircle = 0.07), pkg = "terra")


##### Tree Detection and Segmention

##Detection with local maxima filter
#Douglas Fir
ttops <- locate_trees(npc, lmf(ws = 2.8,hmin = 2))

#Lodgepole Pine
#ttops <- locate_trees(npc, lmf(ws = 1.8,hmin = 2))


#load CHM into memory
chm = chm*1

##Tree Segmentation 
#Douglas Fir
las_silva <- segment_trees(npc, silva2016(chm,ttops,max_cr_factor = 0.3, exclusion = 0.15, ID = "treeID"))

#Lodgepole Pine
#las_silva <- segment_trees(npc, silva2016(chm,ttops,max_cr_factor = 0.4, exclusion = 0.1, ID = "treeID"))

#Calculate Metrics (Areas)
metrics <- crown_metrics(las_silva, func = .stdtreemetrics, geom = "convex")



##### Create initial Datasets
trees_area = metrics
trees_points = ttops

#Join information to point and area 
joint_tree_polygon = st_join(x = trees_area, y = trees_points)
joint_tree_points = st_join(y = trees_area, x = trees_points)

#Clean up Data
tree_dataset_UAV  = joint_tree_polygon[-5,-6]


##### DBH prediction

##Douglas fir (Goodbody et al. 2017)
tree_dataset_UAV$dbh = exp((2.590283 + 0.043808*tree_dataset_UAV$Z-0.001381*tree_dataset_UAV$convhull_area))

##Lodgepole pine (Cortini et al. 2011, eq. 5)
#tree_dataset_UAV$dbh = 3.3821*((tree_dataset_UAV$Z-1.29)^0.5803)*((1.0122^(tree_dataset_UAV$Z-1.29)))*((tree_dataset_UAV$convhull_area^0.128))


##### Conversions
#DBH to inches 
tree_dataset_UAV$dbh_in = tree_dataset_UAV$dbh*0.393701

#Height to feet
tree_dataset_UAV$height_ft = tree_dataset_UAV$Z.x*3.28084



##### Volume Calculation (Woodall et al. 2011)
#parameters douglas fir
b1_df = 0.709
b2_df = 1.153
b3_df = 3.475
b4_df = 3.229
b5_df = 0.001655
b6_df = 1.703
b7_df = 1.217

#parameters lodgepole pine
#b1_lp = 0.688
#b2_lp = 1.032
#b3_lp = 3.58
#b4_lp = 3.405
#b5_lp = 0.002057
#b6_lp = 1.862
#b7_lp = 1.12

V2 = 4



#FIA Volume Equation CU000058 See Woodall et al. 2011,Page 20, Annex RMRS_coefs_7
#For douglas fir, if lodgepole pine, change parameters to _lp
#V1
tree_dataset_UAV$V1 = b5_df*(tree_dataset_UAV$dbh_in^b6_df)*(tree_dataset_UAV$height_ft^b7_df)
#Volume in cubicfoot
tree_dataset_UAV$Volume_total_stem_cubic_foot = (tree_dataset_UAV$V1-(tree_dataset_UAV$V1*(b1_df*(((V2/b2_df)^b3_df)/(tree_dataset_UAV$height_ft^b4_df)))))


#Clean up dataset
tree_dataset_crowns = tree_dataset_UAV %>% 
  rename(
    treeID.x = treeID.x,
    Height_m = Z.x,
    dbh_cm = dbh,
    #cruising = count,
    crown_area_m2 = convhull_area
  )

#join with points
tree_dataset_points = st_join(y = tree_dataset_crowns, x = joint_tree_points, by = "treeID.x")


##### Calculate Number of Trees and Volume on study area (UAV Estimates)


##UAV Estimates
#Select trees that are on study area
tree_dataset_points_overall_sum <- tree_dataset_points[border, ]

#convert to numeric
tree_dataset_points_overall_sum$Volume_total_stem_cubic_foot = as.numeric(tree_dataset_points_overall_sum$Volume_total_stem_cubic_foot)

#Calculate volume on study area (UAV Estimate)
Sum_volume_area_UAV = sum(tree_dataset_points_overall_sum$Volume_total_stem_cubic_foot, na.rm = TRUE)
print("The UAV-Estimate for the overall volume on the study area in cubicfoot is:")
Sum_volume_area_UAV


#Calculate number of trees on study area (UAV Estimate)
Trees_overall_UAV = nrow(tree_dataset_points_overall_sum)
print("The UAV-Estimate for the overall number of trees on the study area is:")
Trees_overall_UAV 

##### End of Basic-Script

#####Validation with BLM Script

##### Calculate Number of Trees and Volume on study area (BLM Cruising)
## calculate area of study area (stand)
area_stand = as.numeric(st_area(border)/4047)

##BLM Cruising
#Calulate volume on Study Area (BLM-Cruising)
Sum_volume_Factor_BLM = sum(trees_BLM$`Volume Factor`)

#Multiply Volume Factor with Area
Sum_volume_area_BLM = Sum_volume_Factor_BLM*area_stand
print("The BLM-Cruising-Estimate for the overall volume on the study area in cubicfoot is:")
Sum_volume_Factor_BLM*area_stand


#Calulate number of trees on Study Area (BLM-Cruising)
Sum_Tree_Factor_BLM = (sum(trees_BLM$`Tree Factor`))
Trees_overall_BLM = Sum_Tree_Factor_BLM*area_stand
print("The BLM-Cruising-Estimate for the overall number of trees on the study area is:")
Trees_overall_BLM

###### Comparision/Validation

#Calculate the Difference in Volume
Diff_Volume = Sum_volume_area_UAV-Sum_volume_area_BLM

#Calculate the Percentage (in Volume) / Volume Prediction Rate
Percentage_Volume = Sum_volume_area_UAV/Sum_volume_area_BLM 


#Print results (Volume)
print(paste("The difference in volume [cft] is:", round(Diff_Volume,2)))
print(paste("The Volume Prediciton Rate is:", round(Percentage_Volume,3)))



#Calculate the difference for the overall number of trees
Diff_Trees = Trees_overall_UAV-Trees_overall_BLM

#Calculate the percentage for the overall number of trees/ Tree Detection Rate
Percentage_Trees = Trees_overall_UAV/Trees_overall_BLM

#Print results (Number of trees)
print(paste("The difference in the overall number of trees is", round(Diff_Trees,2)))
print(paste("The Tree Detection Rate is:", round(Percentage_Trees,3)))









