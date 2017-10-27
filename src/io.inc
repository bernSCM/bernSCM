c     Input/Output setup

      character*1000
     $     indir                !input directory containting forcing files
     $     ,outdir              !output directory
     $     ,outpath             !path to output file
     $     ,forcpath            !path to forcing file
     $     ,scenario            !Identifier of forcing scenario
     $     ,ID                  !additional identifier (manually specified in run file)
      integer                   !corresponding file units
     $     iforcingfile
     $     ,ioutpath
     $     ,iforcpath

      parameter(indir='./forcing/',outdir='./output/')
      parameter(iforcingfile=31,ioutpath=32,iforcpath=33)


      real*8, pointer :: forcing(:,:) ! array of forcings (boundary conditions read from forcing file)

      integer
     $     nforc                !number of forcings
     $     ,nin                 !number of input time steps
!     column index of each forcing:
     $     ,jtime               !timed (yr)
     $     ,jTemp               !temperature (K)
     $     ,jRFnC               !non-CO₂ RF (Wm⁻²)              
     $     ,jRFB                !budget RF (Wm⁻²)
     $     ,jaCO2               !atmospheric CO₂ (ppm)
     $     ,jeCO2               !anthropogenic C emissions (Gt/yr)
     $     ,jfB                 !budget C uptake (Gt/yr)

      parameter(nforc=7
     $     ,jtime=1
     $     ,jTemp=2
     $     ,jRFnC=3
     $     ,jRFB=4 
     $     ,jaCO2=5  
     $     ,jeCO2=6
     $     ,jfB=7  
     $     )



      common /IO/ outpath,scenario,ID,nin,forcing
