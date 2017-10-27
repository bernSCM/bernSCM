      program bernSCMmain

#include "control.inc"

      include 'general.inc'
      include 'io.inc'

      integer i,n               !counters

      dt=deltat                 !timestep from control.inc


c     interactive input

      write (0,901)
 901  format ('Climate sensitivity (K): ',A)
      read (*,*) T2x

      write (0,902)
 902  format ('T dependence (.true./.false.): ',A)
      read (*,*) Tdep

      write (0,903)
 903  format ('Co2 dependence (.true./.false.): ',A)
      read (*,*) CO2dep

      write (0,904)
 904  format ('scenario (string as in file name forcing_<scenario>.dat): ',A)
      read (*,*) scenario

      write (0,905)
 905  format ('additional simulation identifier (string, enter " " to skip): ',A)
c      read (*,*,err=906,end=906) ID
      read (*,*,end=906) ID

 906  if(trim(ID).le."")then
        call getenv('ID', ID)   !if ID not given, try to read environment variable
      endif

      call readforcing

      call initialize

      call openouts


      n=1 !time step 1
      call setforcing(n)

c     set preindustrial equilibrium CO2 concentration for ocean exchange
c     make sure the first record of the forcing file contains this reference
c     concentration as an initial condition
      co2_atm0=mA(1)/ppmtoGt
        
      do n=2,ntime

        call setforcing(n)
        call timestep(n)

      enddo

      call output

      call closeouts

      end




