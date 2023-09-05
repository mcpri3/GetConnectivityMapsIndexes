rm(list=ls())
lst.files <- list.files(here::here('data/derived-data/OmniscapeParamFiles/'))
lst.files <- paste0(here::here('data/derived-data/OmniscapeParamFiles/'), lst.files)
unlink(lst.files)
combi.doable <- openxlsx::read.xlsx(here::here('data/raw-data/FunctionalGroups/List-of-clustering-schemes.xlsx'))
coef <- c(2, 4, 8, 16)
# coef <- c(0.25, 1, 4, 8, 16, 32)

for (i in 1:nrow(combi.doable)) {
  
  g <- combi.doable$group[i]
  k <- combi.doable$Nclus[i]
  m <- combi.doable$mode[i]
  
  # Read list of SNAP species 
  lst.sp <- openxlsx::read.xlsx(here::here(paste0('data/raw-data/FunctionalGroups/FinalList-of-SNAP-Vertebrate-Species_ActT-Diet-ForagS-NestH-Morpho-HabPref-DispD-MoveMod-LifeHist-PressureTraits_', 
                                                  g, '_GroupID_K=', k, '_Weight-', m,'.xlsx')))
  
  for (c in c(1:k)) {
  
    sub.lst <- lst.sp[lst.sp$cluster.id == c, ]
    dd.thlow <- quantile(sub.lst$dispersal_km, probs = 0.75)
    dd.thhigh <- quantile(sub.lst$dispersal_km, probs = 0.95)
    dd.delta <- dd.thhigh - dd.thlow
    bby <- ifelse(dd.delta > 10, 1, ifelse(dd.delta>1, 0.1, 0.01))
    ddigit <- ifelse(dd.delta > 10, 0, ifelse(dd.delta>1, 1, 2))
    dd.thlow <- round(dd.thlow, digits = ddigit)
    dd.thhigh <- round(dd.thhigh, digits = ddigit)
    dd.range <- seq(dd.thlow, dd.thhigh, by = bby)
    
    if (length(dd.range) >= 5) {
    seq.dd <- sample(dd.range, 5, replace = F)
    } else {
      dd.range <- seq(floor(dd.thlow), ceiling(dd.thhigh), bby)
      seq.dd <- sample(dd.range, 5, replace = F)
    }
    
    for (ccoef in coef) {
      
      for (dispdist in seq.dd) {
    
    config.tplate <- read.table(here::here('data/derived-data/OmniscapeTemplate.ini'))
    colnames(config.tplate)[1] <- "param"
    colnames(config.tplate)[3] <- "val"
    
    config.tplate$val[config.tplate$param == "resistance_file"] <- paste0("/Users/primam/Documents/LECA/NaturaConnect/Rprojects/04_GetConnectivityMapsIndexes/data/raw-data/ResistanceSurfaces/ResistanceSurface_", 
                                                                          g , "_GroupID_", c, "_TransfoCoef_", ccoef,".tif")
    config.tplate$val[config.tplate$param == "source_file"] <- paste0("/Users/primam/Documents/LECA/NaturaConnect/Rprojects/04_GetConnectivityMapsIndexes/data/raw-data/SourceLayers/SourceLayer_", 
                                                                      g, "_GroupID_", c, ".tif")
    config.tplate$val[config.tplate$param == "project_name"] <- paste0("/Users/primam/Documents/LECA/NaturaConnect/Rprojects/04_GetConnectivityMapsIndexes/data/derived-data/OmniscapeOutput/OmniscapeOutput_", 
                                                                       g, "_GroupID_", c, "_TransfoCoef_", ccoef, "_DispDist_", dispdist)
    
    config.tplate$val[config.tplate$param == "radius"] <- dispdist* 1000  #to get it in meters 
    config.tplate <- paste(config.tplate$param, config.tplate$V2, config.tplate$val)
    write.table(config.tplate, here::here(paste0("data/derived-data/OmniscapeParamFiles/IniFile_",g, "_GroupID_", c, "_TransfoCoef_", ccoef, "_DispDist_", dispdist,"km.ini")), quote = F, row.names = F, col.names = F)
      }
    }
  }
}



