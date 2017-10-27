
      type(PIRF) :: Pland=PIRF(
     $     5                    !nscale
     $     ,(/ -0.15431665d0, 0.56172938d0, 0.07486977d0, 0.41365999d0, 0.10405757d0, 0d0, NA /) !weight
     $     ,(/ 0.2010730d0, 1.4753908d0, 8.889799331d0, 74.098061812d0, 2.538054d02, NA, NA /) !tscale
     $     ,"HRBM" !name
     $     )

c     Weights of the decay IRF (derivative of stock IRF)
c     LweightD=(/ -0.7674658, 0.3807326, 0.008421987, 0.005582602, 4.099896e-04, 0 /)
c     Lweight corresponds to LweigthD*Ltscale

      type(SIRF) :: Sland=SIRF( !IRF temperature sensitivity
     $     (/ 0.14d0, 0.056d0, 0.072d0, 0.044d0, 0.069d0, 0d0, NA /) !weight
     $     ,(/ 0.056d0, 0.079d0, 0.057d0, 0.053d0, 0.036d0, NA, NA /) !tscale
     $     ,5d0 !Tmax
     $     )      


      type(DOCU) :: DocuLand=DOCU(
c     component
     $     "#\n# HRBM pulse response/multibox substitute model"       
c     authors
     $     ,""                  
c     references
     $     ,"#\n# - Meyer et al. 1999: The substitution of high-resolution terrestrial biosphere"
     $     //"\n# models and carbon sequestration in response to changing CO2 and climate,"
     $     //"\n# Global Biogeochemical Cycles 13, 785)"
c     description
     $     ,"#\n# The fate of assimilated C as simulated by HRBM is represented by several pools." !description
     $     //"\n# Each pool receives a fraction of global NPP as input, and loses C by heterotrophic"
     $     //"\n# respiration according to a characteristic turnover time. Both input fractions and"
     $     //"\n# Turnover times are dependent on global mean SAT (dynamic vegetation changes are"
     $     //"\n# not captured.)"
     $     //"\n# The box coefficients are derived from a decay-IRF by integrating to an IRF"
     $     //"\n# for the current stored fraction (as in ocean IRFs)."
     $     )

