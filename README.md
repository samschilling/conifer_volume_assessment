# conifer_volume_assessment
The code in this repository analyzes Structure from Motion (SFM) point clouds of coniferous expansion areas and calculates the standing timber volume on the covered areas. This code is part of the Master's Thesis of Samuel Schilling in the for a M.Sc. in Environment and Renewable Science in the research group geoinformation at the Zurich University of Applied Sciences in Waedenswil, ZH, Switzerland (https://www.zhaw.ch/en/lsfm/institutes-centres/iunr/geoecology/geoinformatics/). Additional sources or explanations are provided on request. 

The code was designed using the lidR extension package (Roussel et al., 2020), in R (R Core Team 2022) based on the workflows of Mohan et al. 2021, Shin et al. 2018, Belmonte et al. 2020, and Gülci et al. 2021 to asses the voulume of coniferous expansion in southwestern Montana. The code was designed so it can calculate the volume for two different tree species (Douglas fir and Lodgepole pine). Other tree species could be added by simply changing the parameters and equations to a particular tree species. 

The code consits of three R-scripts. The "Basic Script" contains the base code where only a point cloud (.las) and a perimeter of the study area (.shp) has to be loaded and then the standing timber volume in cubicfeet is calculated. The "single tree validation" script validates the results with a sample of single trees that has to be provided. The validation sample requires the measured trees to have a XY-position, a measurement of the diameter at breast height (DBH) and the total height of every tree within the sample. Finally the "stand validation" script compares the data with a volume estimation that was made using the point sample method according to the   Forest Service Handbook of the U.S. Forest Service (FSH 2409.12 Timber Cruising Handbook, Amendment No. 2409.12-2000-6). The validation data has to be provided. 



02.02.2023, Samuel Schilling



References:



Roussel, J.-R. et al. (2020). “lidR: An R package for analysis of Airborne Laser Scanning (ALS) data”. In: Remote Sensing of Environment 251. Publisher: Elsevier, 
Article Number: 112061. issn: 0034-4257. doi: 10.1016/j.rse.2020.112061.

R Core Team (2022). R: A Language and Environment for Statistical Computing. R Foundation for Statistical Computing. Vienna, Austria.

Mohan, M. et al. (2021). “Individual tree detection using UAV-lidar and UAV-SfM data: A tutorial for beginners”. In: Open Geosciences 13.1. 
Publisher: De Gruyter Open Access, pp. 1028–1039. issn: 2391-5447. doi: 10.1515/geo-2020-0290.

Shin, P. et al. (2018). “Evaluating Unmanned Aerial Vehicle Images for Estimating Forest Canopy Fuels in a Ponderosa Pine Stand”. In: Remote Sensing 10.8.
Publisher: Multidisciplinary Digital Publishing Institute, Article Number: 1266. issn: 2072-4292. doi: 10.3390/rs10081266.

Belmonte, A. et al. (2020). “UAV-derived estimates of forest structure to inform ponderosa pine forest restoration”. In: Remote Sensing in Ecology and Conservation 6.2. Publisher: Wiley, pp. 181–197. issn: 2056-3485. doi:10.1002/rse2.137.

Gülci, S. et al. (2021). “An assessment of conventional and drone-based measurements for tree attributes in timber volume estimation: A case study on stone pine plantation”. In: Ecological Informatics 63. Publisher: Elsevier, Article Number: 101303. issn: 1574-9541. doi: 10.1016/j.ecoinf.2021.101303.

