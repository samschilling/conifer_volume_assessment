#####Validation with BLM Script
#This script is made to validate measurements on stand level. Field data according to the Foresters Handbook of th U.S. Forest Service (Point Sampling) is required. 


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


##### End of Script