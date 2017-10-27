
      type(PIRF) :: Pland=PIRF(
     $     4                    !nscale
     $     ,(/ 2.006028671730d0, 0.26828d0, -1.56754896028d0, 0.29323d0, 0d0, NA, NA /) !weight
     $     ,(/2.857143d0,       20d0, 2.181818d0,       100d0, NA, NA, NA /) !tscale
     $     ,"4box" !name
     $     )

      type(DOCU) :: DocuLand=DOCU(
c     component
     $     "#\n# 4-box Biosphere of Bern Model"       
c     authors
     $     ,""                  
c     references
     $     ,"#\n# Ref: F. Joos, M. Bruno, R. Fink, T. F. Stocker,"
     $     //"\n# U. Siegenthaler and F. Joos, 1992: Use of a simple model"
     $     //"\n# for studying oceanic tracer distributions and the global carbon cycle,"
     $     //"\n# Tellus, Ser. B, 44, 186-207, 1992."
c     description
     $     ,"#\n# Global box model consisting of four pools representing ground vegetation," !description
     $     //"\n# wood, detritus and soil organic carbon, with each reservoir having a distinct"
     $     //"\n# turnover time independent of environmental conditions (SAT)."
     $     )
 
