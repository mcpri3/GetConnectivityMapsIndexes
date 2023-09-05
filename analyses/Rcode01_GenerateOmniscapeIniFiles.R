rm(list=ls())
lst.files <- list.files(here::here('data/derived-data/OmniscapeParamFiles/'))
lst.files <- paste0(here::here('data/derived-data/OmniscapeParamFiles/'), lst.files)
unlink(lst.files)
combi.doable <- openxlsx::read.xlsx(here::here('data/raw-data/FunctionalGroups/List-of-clustering-schemes.xlsx'))
coef <- c(2, 4, 8, 16) #hab suit to resistance transformation
thre.lst <- seq(0.5, 0.8, by = 0.1) #threshold to define source from hab suit 

for (i in 1:nrow(combi.doable)) {
  
  g <- combi.doable$group[i] #general group  
  k <- combi.doable$Nclus[i] #total number of clusters in group 
  m <- combi.doable$mode[i] #way variables were weighted to get groups 
  
  # Read list of SNAP species 
  lst.sp <- openxlsx::read.xlsx(here::here(paste0('data/raw-data/FunctionalGroups/FinalList-of-SNAP-Vertebrate-Species_ActT-Diet-ForagS-NestH-Morpho-HabPref-DispD-MoveMod-LifeHist-PressureTraits_', 
                                                  g, '_GroupID_K=', k, '_Weight-', m,'.xlsx')))
  
  for (c in c(1:k)) { #for each group c 
  
    sub.lst <- lst.sp[lst.sp$cluster.id == c, ]
    var.dd <- sd(sub.lst$dispersal_km) #evaluate how DD varies within the group 
    n.dd <- ifelse(var.dd <= 4, 2, ifelse(var.dd <= 10, 4, ifelse(var.dd <= 50, 8, 12))) # number of DD tested as a function of how DD varies within the group, if large variation then higher number of DD tested 
    
    dd.thlow <- min(sub.lst$dispersal_km) 
    dd.thhigh <- max(sub.lst$dispersal_km) 
    dd.delta <- dd.thhigh - dd.thlow
    bby <- ifelse(dd.delta > 4, 1, ifelse(dd.delta>1, 0.1, 0.01))
    ddigit <- ifelse(dd.delta > 4, 0, ifelse(dd.delta>1, 1, 2))
    dd.thlow <- round(dd.thlow, digits = ddigit)
    dd.thhigh <- round(dd.thhigh, digits = ddigit)
    dd.range <- seq(dd.thlow, dd.thhigh, by = bby)
    dd.range <- dd.range[dd.range!= 0]
    
    seq.dd <- sort(sample(dd.range, n.dd, replace = F))

    lst.param <- expand.grid(TransfoCoef = coef, DD = seq.dd, SourceThre = thre.lst)
    
    for (j in 1:nrow(lst.param)) {
    
    transfocoef <- lst.param$TransfoCoef[j]
    dd <- lst.param$DD[j]
    sourcethre <- lst.param$SourceThre[j]
    
    config.tplate <- read.table(here::here('data/derived-data/OmniscapeTemplate.ini'))
    colnames(config.tplate)[1] <- "param"
    colnames(config.tplate)[3] <- "val"
    
    config.tplate$val[config.tplate$param == "resistance_file"] <- paste0("/Users/primam/Documents/LECA/NaturaConnect/Rprojects/04_GetConnectivityMapsIndexes/data/raw-data/ResistanceSurfaces/ResistanceSurface_", 
                                                                          g , "_GroupID_", c, "_TransfoCoef_", transfocoef,".tif")
    config.tplate$val[config.tplate$param == "source_file"] <- paste0("/Users/primam/Documents/LECA/NaturaConnect/Rprojects/04_GetConnectivityMapsIndexes/data/raw-data/SourceLayers/SourceLayer_", 
                                                                      g, "_GroupID_", c, "_SuitThreshold_",sourcethre,".tif")
    config.tplate$val[config.tplate$param == "project_name"] <- paste0("/Users/primam/Documents/LECA/NaturaConnect/Rprojects/04_GetConnectivityMapsIndexes/data/derived-data/OmniscapeOutput/OmniscapeOutput_", 
                                                                       g, "_GroupID_", c, "_TransfoCoef_", transfocoef, "_SuitThreshold_", sourcethre,"_DispDist_", dd)
    
    config.tplate$val[config.tplate$param == "radius"] <- dd* 1000  #to get it in meters 
    config.tplate <- paste(config.tplate$param, config.tplate$V2, config.tplate$val)
    write.table(config.tplate, here::here(paste0("data/derived-data/OmniscapeParamFiles/IniFile_",g, "_GroupID_", c, "_TransfoCoef_", transfocoef,  "_SuitThreshold_", sourcethre,"_DispDist_", dd,"km.ini")), 
                quote = F, row.names = F, col.names = F)
    }
  }
}




