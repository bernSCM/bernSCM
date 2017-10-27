C     GENERAL CONSTANTS

      implicit none

      real*8
     $     dt                   !timestep (yr)
     $     ,ppmtoGt             !C mass equivalent for Atmospheric CO₂ concentration (ppm/GtC)
     $     ,Mumol               !Micromole mass of carbon (g/μmol)
     $     ,Ofrac               !Ocean fraction of earth surface
     $     ,Peta                !factor 10E15 for scaling g/Pg, W/PW
     $     ,reCO2               !rad. efficiency parameter for CO₂
     $     ,log2                !log(2)
     $     ,RF2x                !RF for CO₂ doubling
     $     ,sectoyear           !seconds per year (s/yr, joos PR)
     $     ,co2preind           !reference preindustrial CO₂ for RF calculation (ppm)


      parameter(
     $     ppmtoGt=2.123D0
     $     ,Mumol=12.0107D-6
     $     ,Ofrac=0.71D0
     $     ,Peta=1D15
     $     ,reCO2=5.35D0
     $     ,log2=0.6931471805599453
     $     ,sectoyear=365D0*24D0*3600D0
     $     ,co2preind=278.6822074d0
     $     )

      parameter(RF2x=reCO2*log2)

      real*8 co2_atm0 !set later to initial value

c     PHYSICAL VARIABLES

      real*8 T2x                !T equilibrium change for CO2 doubling, climate sensitivity (K)
      logical 
     $     Tdep                 !Temperature dependence
     $     ,CO2dep              !CO2 dependence
     $     ,Fbudget,RFbudget,CO2budget !C budget case

      real*8 NA,NAinput         !undefined value

      parameter(NA=-9999.9999d0)
      parameter(NAinput=NA)

      integer ntime             !number of time steps
      integer*8, pointer :: itime(:)

c     state variables
      real*8, pointer ::
     $     time(:)              !model time (yr)
     $     ,Temp(:)             !global mean SAT deviation from preindustrial (K)
     $     ,Tempk(:)            !global mean SAT box components
     $     ,RFnC(:)             !non-CO₂ radiative forcing (Wm⁻²)
     $     ,RFC(:)              !CO₂ radiative forcing (Wm⁻²)
     $     ,RFB(:)              !budget radiative forcing (Wm⁻²)
     $     ,RF(:)               !total radiative forcing (Wm⁻²)
     $     ,fH(:)               !air-sea heat flux (PW)
     $     ,dpCs(:)             !ocean surface CO₂ saturation partial pressure deviation from preindustrial (ppm)
     $     ,mA(:)               !mass of C in atmosphere (GtC)
     $     ,mS(:)               !mass of C in ocean surface layer (GtC)
     $     ,mSk(:)              !ocean C surface pools (GtC)
     $     ,mL(:)               !mass of C in land biosphere (GtC)
     $     ,mLk(:)              !land biosphere C pools (GtC)
     $     ,eCO2(:)             !CO₂ emissions (GtC/yr)
     $     ,fB(:)               !budget C uptake (GtC/yr)
     $     ,fNPP(:)             !NPP (GtC/yr)
     $     ,fO(:)               !air-sea C flux (GtC/yr) 

      integer
     $     nscalemax             !maximal number of finite timescales of boxes
      parameter(nscalemax=10)

      TYPE :: PIRF              !IRF parameter set
      sequence
      integer   :: nscale       !number of finite timescales
      real*8    :: weight(nscalemax+1) !weight or fraction of input for each box
      real*8    :: tscale(nscalemax+1) !time scales of each box (yr)  
      character*12 :: name      !name of IRF
      END TYPE PIRF

      TYPE :: SIRF              !IRF temperature sensitivities
      sequence
      real*8    :: weight(nscalemax+1) !T sensitivity of weights
      real*8    :: tscale(nscalemax+1) !T sensitivity of tscales
      real*8    :: Tmax             !parametrization range
      END TYPE SIRF

      TYPE :: DOCU              !documentation
      sequence
      character*1000    :: component
      character*1000    :: authors
      character*1000    :: references
      character*1000    :: description
      END TYPE DOCU


      common /general/ dt,co2_atm0,T2x,Tdep,CO2dep,itime,ntime,time,Temp,Tempk,RFnC,RFC,RFB,RF,fH
     $     ,dpCs,mA,mS,mSk,mL,mLk,eCO2,fB,fNPP,fO,Fbudget,RFbudget,CO2budget



      type(DOCU) :: DocuGeneral=DOCU(
c     component
     $     "# Bern Simple Climate Model (BernSCM) version 1.0"
c     author
     $     ,"# Kuno Strassmann, Fortunat Joos\n"
     $     //"# Climate and Environmental Physics\n"
     $     //"# Sidlerstr 5\n"
     $     //"# CH-3012 Bern\n"
     $     //"# kuno.strassmann@alumni.ethz.ch, joos@climate.unibe.ch\n"
     $     //"# Tel.: 0041-31-631 44 61"
c     References
     $     ,"#"
     $     //"\n# - K. Strassmann and F. Joos, 2017: The Bern Simple Climate Model: an extensible and fully"
     $     //"\n# documented open source reimplementation of the Bern reduced form model for global carbon"
     $     //"\n# cycle-climate simulations. Submitted to Geophysical Model Development."
     $     //"\n# - F. Joos, M. Bruno, R. Fink, T. F. Stocker, U. Siegenthaler, C. Le Quere, and"
     $     //"\n# J. L. Sarmiento, 1996: An efficient and accurate representation of complex oceanic"
     $     //"\n# and biospheric models of anthropogenic carbon uptake. Tellus, 48B:397-417"
     $     //"\n# - Joos, F. and M. Bruno, 1996: Pulse response functions are cost-efficient tools to model the link" 
     $     //"\n# between carbon emissions, atmospheric CO2 and global warming. Physics and Chemistry of the Earth"
     $     //"\n# 21:471-476."
c     description
     $     ,"#"
     $     //"\n# The model is based on impulse response representation (Joos et al., 1996) of the ocean (surface-to-deep"
     $     //"\n# transport) and the terrestrial biosphere (accumulation and decay of NPP carbon). Nonlinear ocean surface carbon"
     $     //"\n# chemistry and NPP changes are treated by separate parametrizations (see description of C cycle components below)."
     $     )

