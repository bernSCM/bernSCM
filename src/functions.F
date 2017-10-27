#include "control.inc"

      function interpol(x,x0,x1,y0,y1) !Interpolation

      include 'general.inc'
      real*8 interpol
      real*8
c     input:
     $     x,x0,x1              ! x-values for interpolation
c     output:
     $     ,y0,y1,y             ! y(x) interpol. value

      
      if(y0==NA)then
        y = NA
        if(abs(x-x1)<1d-9)then
          y = y1
        else
          y = NA
        endif
      else if(y1==NA)then
         if(abs(x-x0)<1d-9)then
         y = y0
        else
          y = NA
        endif
      else
        y = ((x-x0)*y1 + (x1-x)*y0)/(x1-x0)
      endif

      interpol=y

      
      return      

      end


      function npp(m,T,deriv)

      include 'general.inc'
      real*8
c     output:
     $     NPP                  ! NPP (GtC/yr) or dNPP/dm (GtC/yr/GtC)
c     input: 
     $     ,m                   !atmospheric CO₂ (GtC)
     $     ,T                   !global ΔSAT (℃)
      logical deriv             !return derivative dNPP/dm
c     local:
      real*8 NPPdev             ! dNPP/dm (GtC/yr/GtC)
      
      include 'parNPP.inc'
      include 'npp.finc'

      return      

      end


      function fasC(Ca,dpCO2s)

      include 'general.inc'
      include 'parOcean.inc'

      real*8
c     output:
     $     fasC                 !Atmosphere-ocean CO2 flux (Gt/yr)
c     input:
     $     ,Ca                  !atmospheric CO2 concentration (Gt)
     $     ,dpCO2s              !ocean saturation CO2 pressure deviation from preindustrial equilibrium (ppm)
c     local
     $     ,dCa                 !atmospheric CO2 concentration change (Gt)

      dCa = Ca-co2_atm0*ppmtoGt
      fasC= KgAoc * (dCa-dpCO2s*ppmtoGt)

      end function fasC



      function fasT(RFtot,T)

      include 'general.inc'
      include 'parOcean.inc'
      real*8
c     output:
     $     fasT                 !air-sea heat flux (PW)
c     input:
     $     ,RFtot               !radiative forcing (Wm⁻²)
     $     ,T                   !global near-surface atmospheric temperature deviation (℃)

      if(T2x>0d0)then
        fasT=(Aoc/Ofrac/Peta)*(RFtot-(T/T2x)*RF2x)
      else
        fasT=0d0 ! T is always in equilibrium
      endif

      end function fasT


      function RFco2(m)

      include 'general.inc'
      real*8
c     output:
     $     RFco2                !RF of atmospheric CO2 (Wm⁻²)
c     input:
     $     ,m                   !atmospheric CO₂ (Gt)
      
      RFco2=reCO2*log((m/ppmtoGt)/co2preind)
      
      end function RFco2


      function RFeqCO2mA(RFco2) !calculate equivalent atmospheric CO2 (in GtC) from RF

      include 'general.inc'
      real*8
c     output:
     $     RFeqCO2mA            !atmospheric CO₂ (Gt)
c     input:
     $     ,RFco2                !CO2 RF (Wm⁻²)
      
      RFeqCO2mA=exp(RFco2/reCO2)*co2preind*ppmtoGt
      
      end function RFeqCO2mA



      function dpCO2s(dDIC,T,deriv)

      include 'general.inc'
      include 'parOcean.inc'

      real*8
c     output:
     $     dpCO2s               !ocean saturation CO2 pressure deviation from preindustrial equilibrium (ppm),
c     !                          or derivative (d dpCs/d dDIC)
c     input:
     $     ,dDIC                !change in ocean surface DIC (μmol:kg)
     $     ,T                   !global SAT change from preindustrial (℃)
      logical deriv             !return derivative dpCO2s/ddDIC      
c     local:
      real*8 dpCO2sdev          !derivative (d dpCs/d dDIC)
      include 'parOchem.inc'
      include 'Ochem.finc'
      
      end function dpCO2s



