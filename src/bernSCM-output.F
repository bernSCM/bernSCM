c     compiler flags to control output (see below)
#define dointerpol 1

      subroutine output

      
#include "control.inc"
      include 'general.inc'
      include 'io.inc'
      include 'parLand.inc'
      include 'parNPP.inc'
      include 'parOcean.inc'
      include 'parOchem.inc'
      include 'functions.inc'

c     local
      integer n,i               !counters
      integer date(8)
      data date /0,0,0,0,0,0,0,0/
      character*12 fheader,ftable !output formats
      
c     local derived vars for output
      real*8, pointer ::
     $     co2_atm(:)           !atmospheric CO2 (ppm)
     $     ,fA(:)               !atmospheric CO2 change (GtC/yr)
     $     ,fRH(:)              !heterotrophic respiration (GtC/yr)
     $     ,fossil_emissions(:) !fossil/anthro emissions (GtC/yr
     $     ,NPPout(:)           !NPP (GtC/yr)
     $     ,land_C_uptake(:)    !net ecosystem production (GtC/yr)
     $     ,ocean_C_uptake(:)   !ocean uptake (GtC/yr)
     $     ,fdeep(:)            !C flux from mixed layer to deep (GtC/yr)
     $     ,midtime(:)          !mid-dt centered time (yr)

      real*8, pointer :: test(:)

      allocate(co2_atm(ntime),fA(ntime),fRH(ntime),land_C_uptake(ntime),ocean_C_uptake(ntime)
     $     ,fdeep(ntime),fossil_emissions(ntime),NPPout(ntime),midtime(ntime))

      allocate(test(ntime))

c     calculate derived vars
      co2_atm(:) = mA(:)/ppmtoGt

      do n=2,ntime
        if(RF(n)==NA.or.RFnC(n)==NA.or.RFC(n)==NA)then
          RFB(n)=NA
        else
          RFB(n)=RF(n)-RFnC(n)-RFC(n)
        endif
      enddo

      fA(:) = 0d0
      fRH(:) = NPP0
      NPPout(:) = NPP0
      land_C_uptake(:)=0d0
      ocean_C_uptake(:)=0d0
      fossil_emissions(:)=0d0
      fdeep(:)=0d0

#if linear
c     C budget as in code
c     The following fluxes correspond to midtime (box-centered)
      do n=2,ntime
        fA(n)=(mA(n)-mA(n-1))/dt
        fossil_emissions(n)=(eCO2(n)+eCO2(n-1))/2d0
        ocean_C_uptake(n)=(fO(n)+fO(n-1))/2d0
        land_C_uptake(n)=(mL(n)-mL(n-1))/dt
        NPPout(n)=(fNPP(n)+fNPP(n-1))/2d0
        fRH(n) = fNPP(n) - land_C_uptake(n)
        fB(n) = fossil_emissions(n) - fA(n) - ocean_C_uptake(n) - land_C_uptake(n)
      enddo

#else
c     C budget as in code
c     The following fluxes correspond to midtime (box-centered)
      do n=2,ntime
        fA(n)=(mA(n)-mA(n-1))/dt
        fossil_emissions(n)=(eCO2(n)+eCO2(n-1))/2d0
        ocean_C_uptake(n)=fO(n)
        land_C_uptake(n)=(mL(n)-mL(n-1))/dt
        fRH(n) = fNPP(n) - land_C_uptake(n)
        fB(n) = fossil_emissions(n) - fA(n) - ocean_C_uptake(n) - land_C_uptake(n)
      enddo
      NPPout=fNPP

#endif

#if dointerpol
c     interpolate to edges (taking shift into account)
      do n=1,ntime-1
        fA(n)=(fA(n)+fA(n+1))/2
        ocean_C_uptake(n)=(ocean_C_uptake(n)+ocean_C_uptake(n+1))/2
        land_C_uptake(n)=(land_C_uptake(n)+land_C_uptake(n+1))/2
        fossil_emissions(n)=(fossil_emissions(n)+fossil_emissions(n+1))/2
      enddo
      fB = fossil_emissions-fA-land_C_uptake-ocean_C_uptake !budget sink
      fRH=land_C_uptake-NPPout
#endif

#if !dointerpol
c output mid-time values
      midtime=time-dt/2
#endif

c write output
      call date_and_time(values=date)
 771  format('# Creation date: ',I4,'/',I2,'/',I2,' ',I2,':',I2,':',I2)
      write(ioutpath,771) date(1:3),date(5:7)

c     self-documentation of individual model components
      call docu_component(DocuGeneral)
      call docu_setup !documentation of model setup for simulation
      call docu_component(DocuOcean)
      call docu_component(DocuOchem)
      call docu_component(DocuLand)
      call docu_component(DocuNPP)


c     Data output

c     header with units
#if dointerpol
      fheader='(A338)'
#else
c     output mid-time values
      fheader='(A351)'
#endif

      write(ioutpath,fheader)
     $     '#time_(yr)'
     $     //' glob_temp_dev_(℃)'
     $     //' RF_tot_(W/m²)'
     $     //' RF_CO2_(W/m²)'
     $     //' RF_nonCO2_(W/m²)'
     $     //' RF_budget_(W/m²)'
     $     //' ocean_heat_uptake_(PW)'
     $     //' co2_atm_(ppm)'
     $     //' co2_seasurf_(ppm)'
     $     //' atm_CO2_change_(GtC/yr)'
     $     //' fossil_CO2_em_(GtC/yr)'
     $     //' budget_C_uptake_(GtC/yr)'
     $     //' ocean_C_uptake_(GtC/yr)'
     $     //' land_C_uptake_(GtC/yr)'
     $     //' NPP_(GtC/yr)'
     $     //' RH_(GtC/yr)'
     $     //' LandC_(GtC)'
     $     //' dDIC_(μmol/kg)'
     $     //' fdeep_(GtC/yr)'
#if ! dointerpol
     $     //' midtime_(yr)'
#endif

c     header without units
#if dointerpol
      fheader='(A189)'
      ftable='(19G20.10)'
#else
      fheader='(A197)'
      ftable='(20G20.10)'
#endif

      write(ioutpath,fheader)
     $     '#time'
     $     //' glob_temp_dev'
     $     //' RF_tot'
     $     //' RF_CO2'
     $     //' RF_nonCO2'
     $     //' RF_budget'
     $     //' ocean_heat_uptake'
     $     //' co2_atm'
     $     //' co2_seasurf'
     $     //' atm_CO2_change'
     $     //' fossil_CO2_em'
     $     //' budget_C_uptake'
     $     //' ocean_C_uptake'
     $     //' land_C_uptake'
     $     //' NPP'
     $     //' RH'
     $     //' LandC'
     $     //' dDIC'
     $     //' fdeep'
#if !( dointerpol)
     $     //' midtime'
#endif

c     data
      do n=1,ntime
        write(ioutpath,ftable)
     $       time(n)
     $       ,Temp(n)
     $       ,RF(n)
     $       ,RFC(n)
     $       ,RFnC(n)
     $       ,RFB(n)
     $       ,fH(n)
     $       ,mA(n)/ppmtoGt
     $       ,co2_atm0+dpCs(n)
     $       ,fA(n)
     $       ,fossil_emissions(n) !eCO2(n)
     $       ,fB(n)
     $       ,ocean_C_uptake(n)
     $       ,land_C_uptake(n)
c     $       ,fNPP(n)
     $       ,NPPout(n)
     $       ,fRH(n)
     $       ,mL(n)
     $       ,mS(n)
c     *parOcean$mC
     $       ,fdeep(n)
#if !( dointerpol)
     $       ,midtime(n)
#endif
      enddo

      end subroutine output 





      subroutine openouts
c     open output files
      
#include "control.inc"
      include 'general.inc'
      include 'io.inc'

      include 'parLand.inc'
      include 'parOcean.inc'

c     constructing unique output filename

      character*16
     $     Xdt                  !string for timestep
     $     ,Fdt                 !timestep format
     $     ,Xlin                !indicator for linear discretization
     $     ,Ximp                !indicator for implicit step
     $     ,Xlag                !indicator for lagged step
     $     ,Xscheme             !combined indicator of numerical scheme
     $     ,Xmodel              !model name
     $     ,Xsens               !CC sensitivity case indicator
     $     ,FT2x                !CS format
      
      integer vork,nachk        !auxiliary

#if implicitO
#if implicitL
      Ximp="I"                  !implicit step
#else
      Ximp="Io"                 !ocean-only implicit step
#endif
#else
      Ximp=""
#endif

#if linear
      Xlin="Q"
#else
      Xlin=""
#endif

#if lagged
      Xlag="L"
#else
      Xlag=""
#endif


c     calculate string indicating timestep
      vork=max(1,int(log10(1d-5+dt))+1)
      nachk=-floor(log10(1d-5+dt-int(dt)))
      if(nachk.gt.4) then
        nachk=0
        write(Fdt,'("(I",I1,")")') vork
        write(Xdt,Fdt) int(dt)
      else
        write(Fdt,'("(F",I1,".",I1,")")') vork+nachk+1,nachk
        write(Xdt,Fdt) dt
      endif

      Xmodel="BernSCM"

      if (Tdep) then
        Xsens='_t'
      else
        Xsens='_t0'
      endif
      if(CO2dep)then
        Xsens=trim(Xsens)//'_f'
      else
        Xsens=trim(Xsens)//'_f0'
      endif

c     alternative naming for CC setup:
c      Xsens=''
c      if (Tdep) then
c        if(CO2dep)then
c          Xsens=trim(Xsens)//'_coupled'
c        else
c          Xsens=trim(Xsens)//'_Tonly'
c        endif
c      else
c        if(CO2dep)then
c          Xsens=trim(Xsens)//'_Conly'
c        else
c          Xsens=trim(Xsens)//'_uncoupled'
c        endif
c      endif


c     calculate string indicating T2x (in decigrades to avoid dot in filename!)
      vork=int(log10(1d-1+T2x*10d0))+1
      write(FT2x,'("(A,""_CS"",I",I1")")') vork

      write(Xsens,FT2x) trim(Xsens),int(T2x*10+0.5d0) !CS in dezi℃

      Xscheme='_D'//trim(Xdt)//trim(Xlin)//trim(Ximp)//trim(Xlag)

      if (trim(ID).gt."") then
        ID="_"//trim(ID)//"_"
      else
        ID="_"
      endif
      outpath = trim(outdir)//trim(scenario)//trim(Xscheme)//trim(ID)//trim(Xmodel)//trim(Xsens)//'.dat'
      
      open(ioutpath,file=outpath,status='unknown')
      write (0,902) trim(outpath)
 902  format ('output file: ',A)

      end subroutine openouts



      subroutine closeouts
c     close output files
      include 'io.inc'
      close(ioutpath)
c      write (0,903) trim(outpath)
 903  format ('closed file: ',A)
      end subroutine closeouts


      subroutine docu_component(D)
c     format self-documentation of model components 

      include 'general.inc'
      include 'io.inc'
      type(docu) :: D
      character*100 line
      character*100 fline

      line="# = = = = = = = = = = = = = = = = = = = = = = = = = = = ="

      if(trim(D%component).ne."")then
       write(ioutpath,'(A,A)') "#\n",trim(D%component)
       write(fline,'("(A",I2,")")') len_trim(D%component)
       write(ioutpath,fline) line
      endif
      if(trim(D%authors).ne."")then
        write(ioutpath,'(A)') "#\n# Authors:"
        write(ioutpath,'(A)') trim(D%authors)
      endif
      if(trim(D%description).ne."")then
        write(ioutpath,'(A)') "#\n# Description:"
        write(ioutpath,'(A)') trim(D%description)
      endif
      if(trim(D%references).ne."")then
        write(ioutpath,'(A)') "#\n# References:"
        write(ioutpath,'(A)') trim(D%references)
      endif
      write(ioutpath,'(A)') "#\n#"
      
      end subroutine docu_component


      subroutine docu_setup
c     document model setup for simulation

      include 'general.inc'
      include 'io.inc'
      character*100 line
      character*100 fline
      character*100 setupheader

      line="# = = = = = = = = = = = = = = = = = = = = = = = = = = = ="

      setupheader="# Numerical solution"
      write(ioutpath,'(A,A)') "#\n",trim(setupheader)
      write(fline,'("(A",I2,")")') len_trim(setupheader)
      write(ioutpath,fline) line
      write(ioutpath,'(A,F6.2,A)') "# Time step:",dt,"yr"
#if (implicitL || implicitO)      
      write(ioutpath,'(A,F6.2,A)') "# Implicite step: " 
#if implicitL
      write(ioutpath,'(A,F6.2,A)') "# - Land C exchange" 
#endif
#if implicitO
      write(ioutpath,'(A,F6.2,A)') "# - Ocean C and heat exchange" 
#endif
#endif
#if linear
      write(ioutpath,'(A,F6.2,A)') "# Discretization: piecewise linear"
#else
      write(ioutpath,'(A,F6.2,A)') "# Discretization: piecewise constant"
#endif
      write(ioutpath,'(A)') "#\n#"



      setupheader="# Simulation setup"
      write(ioutpath,'(A,A)') "#\n",trim(setupheader)
      write(fline,'("(A",I2,")")') len_trim(setupheader)
      write(ioutpath,fline) line
      write(ioutpath,'(A,A)') "#\n# Forcing scenario: ",trim(scenario)
      write(ioutpath,'(A,F6.2,A)') "#\n# Climate Sensitivity: ",T2X," degrees C per doubling of atm. CO2"
      write(ioutpath,'(A)') "#\n# Carbon Cycle:"
      write(ioutpath,'(A)') "# Process sensitivity to atmospheric CO2:"
      write(ioutpath,'(A)') "# - Ocean CO2 uptake (see ocean component)"
      if (CO2dep) then
        write(ioutpath,'(A)') "# - Land C exchange (see land component)"
      endif
        write(ioutpath,'(A)') "# Process sensitivity to global mean SAT:"
      if (Tdep) then
        write(ioutpath,'(A)') "# - Ocean CO2 uptake (see ocean component)"
#if LandTdep
        write(ioutpath,'(A)') "# - Land C exchange (see land component)"
#endif
      else
        write(ioutpath,'(A)') "# none"
      endif


      end subroutine docu_setup


