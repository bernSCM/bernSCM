c     B2D IRF refitted with 6 finite time scales (one-piece IRF)

      type(PIRF) :: POCEAN=PIRF(
     $     6                    !nscale
     $     ,(/ 0.09467125d0, 0.1029231d0, 0.03928349d0, 0.4593721d0, 0.0129862d0, 0.2702249, 1.3691e-2 /) !weight
     $     ,(/ 2.690038d0, 13.61728d0, 86.79685d0, 0.5762091d0, 337.2983d0, 0.07027151d0, NA /) !tscale
     $     ,"Bern2D"
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
     $     Hmix=50d0
     $     ,Cp=4000d0
     $     ,dens=1028d0
     $     ,densC=1026.5d0
     $     ,Aoc=3.5375d14
     $     ,KgAoc=1d0/7.46d0
     $     ,Tchem=18.2997d0
     $     )


c     calculate derived IRF pars
      parameter(
     $     OmT = Peta*sectoyear/(Hmix*Cp*dens*Aoc)
     $     ,OmC = Peta/Mumol/densC/Hmix/Aoc  
     $     )


c     documentation
      type(DOCU) :: DocuOcean=DOCU(
c     component
     $     "#\n# Bern2.5D ocean mixed layer pulse response"
c     author
     $     ,""
c     references
     $     ,"#\n# - T.F. Stocker, D.G. Wright, L.A. Mysak, 1992: A zonally averaged, coupled ocean-atmosphere"
     $     //"\n# model for paleoclimate studies. J. Clim. 5, 773-797."
     $     //"\n# - F. Joos, M. Bruno, R. Fink, T. F. Stocker, U. Siegenthaler, C. Le Quere, and"
     $     //"\n# J. L. Sarmiento, 1996: An efficient and accurate representation of complex oceanic"
     $     //"\n# and biospheric models of anthropogenic carbon uptake. Tellus, 48B:397-417"
c     description
     $     ,"#\n# The near-linear transport of heat and carbon content perturbations from the preindustrial"
     $     //"\n# equilibrium of the Bern2.5D ocean model (Stocker et al., 1992) is captured by a mixed-layer"
     $     //"\n# pulse-response function (Joos 1996)."
     $     )
