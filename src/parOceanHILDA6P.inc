c     HILDA IRF refitted with 6 finite time scales (one-piece IRF)

      type(PIRF) :: POCEAN=PIRF(
     $     6                    !nscale
     $     ,(/  0.27830433d0, 0.23337218d0, 0.13732822d0, 0.05154051d0, 0.03503318d0, 0.24013944d0, .022936d0 /) !weight
     $     ,(/ 0.45253504d0, 2.19901724d0,  12.03837102d0,  59.58359820d0, 237.30651757d0, 0.03855458d0, NA /) !tscale
     $     ,"HILDA"
     $     )

      real*8
     $     Hmix                 !mixed layer depth (m)
     $     ,Cp                  !Heat capacity (J/kg/K)
     $     ,dens                !water density (kg/m³)
     $     ,densC               !water density (value used for DIC)
     $     ,Aoc                 !Sea Surface Area (m²)
     $     ,KgAoc               !Gas exchange coefficient (1/yr)
     $     ,Tchem               !SST for calculating pCO2~DIC dependence (K); fixed, not=Temp
     $     ,OmT                 !multiplier for heat uptake (K/(PW*yr))
     $     ,OmC                 !GtC→DIC conversion factor (umol/kg/Gt)


      parameter(
     $     Hmix=75d0
     $     ,Cp=4000d0
     $     ,dens=1028d0
     $     ,densC=1026.5d0
     $     ,Aoc=3.62D14
     $     ,KgAoc=1d0/9.06d0
     $     ,Tchem=18.1716d0
     $     )


c     calculate derived IRF pars
      parameter(
     $     OmT = Peta*sectoyear/(Hmix*Cp*dens*Aoc)
     $     ,OmC = Peta/Mumol/densC/Hmix/Aoc  
     $     )


c     documentation
      type(DOCU) :: DocuOcean=DOCU(
c     component
     $     "#\n# HILDA ocean mixed layer pulse response"
c     author
     $     ,""
c     references
     $     ,"#\n# - Joos, F., 1992. Modellierung der Verteilung von Spurenstoffen im Ozean und" 
     $     //"\n# des globalen Kohlenstoffkreislaufes. Phd thesis, Universität Bern."
     $     //"\n# - Siegenthaler, U. and Joos, F., 1992. Use of a simple model for studying"
     $     //"\n# oceanic tracer distributions and the global carbon cycle. Tellus B 44B, 186-207."
     $     //"\n# - F. Joos, M. Bruno, R. Fink, T. F. Stocker, U. Siegenthaler, C. Le Quere, and"
     $     //"\n# J. L. Sarmiento, 1996: An efficient and accurate representation of complex oceanic"
     $     //"\n# and biospheric models of anthropogenic carbon uptake. Tellus, 48B:397-417"
c     description
     $     ,"#\n# The near-linear transport of heat and carbon content perturbations from the preindustrial"
     $     //"\n# equilibrium of the HILDA box-diffusion ocean model is captured by a mixed-layer pulse"
     $     //"\n# response function (Joos 1996). HILDA is calibrated using observed radiocarbon tracers."
     $     )
