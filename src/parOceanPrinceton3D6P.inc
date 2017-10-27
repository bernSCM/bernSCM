c     Princeton 3D model effective mixed layer IRF (only upper leg after 1yr)
C     REFITTED WITH 6 FINITE TIMESCALES

      type(PIRF) :: POCEAN=PIRF(
     $     6                    !nscale
     $     ,(/ 2.27446514d0, 0.06161763d0, 0.03726494d0, 1.28186186d0, 0.01956537d0, -2.70925536d0, 0.01481883d0 /) !weight
     $     ,(/ 1.19761983d0, 16.67585709d0, 65.10188851d0, 2.00904478d0, 347.58378832d0, 1.55213441d0, NA /) !tscale
     $     ,"Princeton3D"
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
     $     Hmix=50.9d0
     $     ,Cp=4000d0
     $     ,dens=1028d0
     $     ,densC=1026.5d0
     $     ,Aoc=3.55d14
     $     ,KgAoc=1d0/7.66d0
     $     ,Tchem=17.7d0
     $     )

c     temper = 17.7d0
      
c     calculate derived IRF pars
      parameter(
     $     OmT = Peta*sectoyear/(Hmix*Cp*dens*Aoc)
     $     ,OmC = Peta/Mumol/densC/Hmix/Aoc  
     $     )

c     documentation
      type(DOCU) :: DocuOcean=DOCU(
c     component
     $     "#\n# Princeton AOGCM ocean effective mixed layer pulse response"
c     author
     $     ,""
c     references
     $     ,"#\n# - Sarmiento, J., Orr, J. and Siegenthaler, U., 1992. A perturbation simulation of CO2 uptake in an ocean" 
     $     //"\n# general circulation model. Journal of Geophysical Research 97, 3621-3645. doi:10.1029/91JC02849."
     $     //"\n# - F. Joos, M. Bruno, R. Fink, T. F. Stocker, U. Siegenthaler, C. Le Quere, and"
     $     //"\n# J. L. Sarmiento, 1996: An efficient and accurate representation of complex oceanic"
     $     //"\n# and biospheric models of anthropogenic carbon uptake. Tellus, 48B:397-417"
c     description
     $     ,"#\n# An effective mixed-layer pulse response is derived by deconvolving an atmospheric pulse response"
     $     //"\n# experiment with the Princeton AOGCM (pulse size 265 ppm), approximating the effect of nonlinearities"
     $     //"\n# arising from the spatial variability of air-sea exchange and local transport. Representation error"
     $     //"\n# in cumulative ocean uptake is <=6% for stabilization scenarios S450 and S750 (better for future"
     $     //"\n# projection."
     $     )


      
