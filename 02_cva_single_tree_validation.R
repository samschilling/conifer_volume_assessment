###### Validation with single trees
#This script is made to validate measurements on single tree level. Field data consisting of measurements of single trees (position, DBH, height) is required. 

#Matching trees to field measurements by position
comparing_tree_dataset_UAV = st_intersects(trees_field,tree_dataset_UAV)


#Write TreeID to identify duplicates
b <- as.numeric(as.character(comparing_tree_dataset_UAV))
trees_field$treeID <- b

#Remove duplicates
trees_field_unique <- trees_field[!duplicated(trees_field$treeID), ]

#Match Information
tree_dataset_UAV = st_drop_geometry(tree_dataset_UAV)
trees_validation = inner_join(trees_field_unique,tree_dataset_UAV,by="treeID")

##Conversions
#Field DBH to inches
trees_validation$dbh_field_in = trees_validation$f_DBH_m*39.3701

#Field height to feet
trees_validation$height_field_ft = as.numeric(trees_validation$f_Ht_m)*3.281

#rename columns
trees_validation = trees_validation %>% 
  rename(
    dbh_UAV_in = dbh_in,
    height_UAV_ft = height_ft  
    
    
  )


#Calculate volume for field measurements
#For douglas fir, if lodgepole pine, change parameters to _lp
#V1
trees_validation$V1_field = b5_df*(trees_validation$dbh_field_in^b6_df)*(trees_validation$height_field_ft^b7_df)
#Volume in cubicfoot
trees_validation$Volume_total_stem_cubic_foot_field = (trees_validation$V1_field -(trees_validation$V1_field*(b1_df*(((V2/b2_df)^b3_df)/(trees_validation$height_field_ft^b4_df)))))




##Create and plot linear regressions

#dbh
fit_dbh = lm(dbh_field_in~dbh_UAV_in, data = trees_validation)
linreg_dbh = ggplot(fit_dbh$model, aes_string(x = names(fit_dbh$model)[2], y = names(fit_dbh$model)[1])) + 
  geom_point(size = 4) +
  stat_smooth(method = "lm", col = "red", size = 3) +
  theme_classic() +
  
  labs(x='UAV Estimates', y='Field Measurements', title='DBH[inch]',subtitle = paste("Adj R2 = ",signif(summary(fit_dbh)$adj.r.squared, 5)))+
  theme(plot.title = element_text(size=40,face="bold", family="Helvetica", color="black"), text = element_text(size = 35,family = "Helvetica",color="black"),axis.line=element_line(size=2,), axis.text.x = element_text(size = 28, colour = "black"), axis.text.y = element_text(size = 28,colour = "black"))

linreg_dbh

#height
fit_height = lm(height_field_ft~height_UAV_ft, data = trees_validation)
linreg_h = ggplot(fit_height$model, aes_string(x = names(fit_height$model)[2], y = names(fit_height$model)[1])) + 
  
  stat_smooth(method = "lm", col = "red",size = 3) +
  geom_point(size=4) +
  
  theme_classic() +
  
  labs(x='UAV Estimates', y='Fied Measurements', title='Height [ft]',subtitle = paste("Adj R2 = ",signif(summary(fit_height)$adj.r.squared, 5)))+
  theme(plot.title = element_text(size=40,face="bold", family="Helvetica", color="black"), text = element_text(size = 35,family = "Helvetica",color="black"),axis.line=element_line(size=2,), axis.text.x = element_text(size = 28, colour = "black"), axis.text.y = element_text(size = 28,colour = "black"))

linreg_h


#volume
fit_volume = lm(Volume_total_stem_cubic_foot_field~Volume_total_stem_cubic_foot, data = trees_validation)
linreg_v = ggplot(fit_volume$model, aes_string(x = names(fit_volume$model)[2], y = names(fit_volume$model)[1])) + 
  geom_point(size = 4) +
  stat_smooth(method = "lm", col = "red",size = 3) +
  theme_classic() +
  labs(x='UAV Estimates', y='Fied Measurements', title='Volume [cft]',subtitle = paste("Adj R2 = ",signif(summary(fit_volume)$adj.r.squared, 5)))+
  theme(plot.title = element_text(size=40,face="bold", family="Helvetica", color="black"), text = element_text(size = 35,family = "Helvetica",color="black"),axis.line=element_line(size=2,), axis.text.x = element_text(size = 28, colour = "black"), axis.text.y = element_text(size = 28,colour = "black"))

linreg_v

##Compare samples with paired t-tests
#DBH
t.test(trees_validation$dbh_UAV_in, trees_validation$dbh_field_in, paired = TRUE, alternative = "two.sided")

#height
t.test(trees_validation$height_UAV_ft, trees_validation$height_field_ft, paired = TRUE, alternative = "two.sided")

#Volume
t.test(trees_validation$Volume_total_stem_cubic_foot, trees_validation$Volume_total_stem_cubic_foot_field, paired = TRUE, alternative = "two.sided")




#Visualize sample comparisons with boxplots
#boxplot dbh
boxplot_comparison_dbh = st_drop_geometry(trees_validation[,c(12,16)])
boxplot_comparison_dbh = rename(boxplot_comparison_dbh, 'UAV Estimates'= dbh_UAV_in,
                                'Field Measurements' = dbh_field_in)



boxplot_comparison_dbh_long = boxplot_comparison_dbh %>%
  pivot_longer(cols = everything(),
               names_to = "categroy",
               values_to = "values")

bp_dbh = ggplot(boxplot_comparison_dbh_long, aes(x=categroy, y=values))+
  geom_boxplot(lwd=1.6,fatten = 1.1,outlier.size=4)+
  theme_classic()+
  theme(plot.title = element_text(size=40,face="bold", family="Helvetica", color="black"), text = element_text(size = 35,family = "Helvetica",color="black"),axis.line=element_line(size=2,), axis.text.x = element_text(size = 28, colour = "black"), axis.text.y = element_text(size = 28,colour = "black"))+
  ggtitle("DBH")+
  scale_x_discrete(name = "", guide=guide_axis(n.dodge=3))+
  scale_y_continuous(name = "DBH [in]", limits=c(0,19))

bp_dbh

#boxplot_height
boxplot_comparison_h = st_drop_geometry(trees_validation[,c(13,17)])
boxplot_comparison_h = rename(boxplot_comparison_h, 'UAV Estimates'= height_UAV_ft,
                              'Field Measurements' = height_field_ft)



boxplot_comparison_h_long = boxplot_comparison_h %>%
  pivot_longer(cols = everything(),
               names_to = "categroy",
               values_to = "values")

bp_h = ggplot(boxplot_comparison_h_long, aes(x=categroy, y=values))+
  geom_boxplot(lwd=1.6,fatten = 1.1,outlier.size=4)+
  theme_classic()+
  theme(plot.title = element_text(size=40,face="bold", family="Helvetica", color="black"), text = element_text(size = 35,family = "Helvetica",color="black"),axis.line=element_line(size=2,), axis.text.x = element_text(size = 28, colour = "black"), axis.text.y = element_text(size = 28,colour = "black"))+
  ggtitle("Height")+
  scale_x_discrete(name = "",guide=guide_axis(n.dodge=3))+
  scale_y_continuous(name = "Height [ft]", limits=c(0,50))


bp_h


#boxplot volume
boxplot_comparison_v = st_drop_geometry(trees_validation[,c(15,20)])
boxplot_comparison_v = rename(boxplot_comparison_v, 'UAV Estimates'= Volume_total_stem_cubic_foot,
                              'Field Measurements' = Volume_total_stem_cubic_foot_field)



boxplot_comparison_v_long = boxplot_comparison_v %>%
  pivot_longer(cols = everything(),
               names_to = "categroy",
               values_to = "values")

bp_v = ggplot(boxplot_comparison_v_long, aes(x=categroy, y=values))+
  geom_boxplot(lwd=1.6,fatten = 1.1,outlier.size=4)+
  theme_classic()+
  theme(plot.title = element_text(size=40,face="bold", family="Helvetica", color="black"),
        text = element_text(size = 35,family = "Helvetica", 
                            color="black"),axis.line=element_line(size=2,), axis.text.x = element_text(size = 28, colour = "black"), axis.text.y = element_text(size = 28,colour = "black"))+
  ggtitle("Volume")+
  scale_x_discrete(name = "",guide=guide_axis(n.dodge=3))+
  scale_y_continuous(name = "Volume [cft]", limits=c(0,22))

bp_v



#plot all graphs in one window
grid.arrange(linreg_dbh,
             linreg_h,
             linreg_v,
             bp_dbh,
             bp_h,
             bp_v, ncol = 3)

##### End of script


