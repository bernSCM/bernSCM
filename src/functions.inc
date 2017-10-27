      real*8 interpol !Interpolation
      external interpol

      real*8 npp                ! NPP (GtC/yr) or dNPP/dm (GtC/yr/GtC)
      external npp
      
      real*8 dpco2s             !ocean saturation CO2 pressure deviation from preindustrial equilibrium (ppm) or derivative (d dpCs/d dDIC)
      external dpco2s

      real*8 RFco2              !RF of atmospheric CO2 (Wm⁻²)
      external RFco2

      real*8 RFeqCO2mA          !calculate equivalent atmospheric CO2 (in GtC) from RF
      external RFeqCO2mA

      real*8 fasT               !air-sea heat flux (PW)
      external fasT

      real*8 fasC               !Atmosphere-ocean CO2 flux (Gt/yr)
      external fasC

      
