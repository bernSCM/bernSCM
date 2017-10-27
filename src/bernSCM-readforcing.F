#include "control.inc"

      subroutine readforcing
c     read forcing (boundary conditions driving simulation)
      include 'general.inc'
      include 'io.inc'

c     local variables
      real*8 frecord(nforc)     !auxiliary, one record of data
      integer i,j               !counters

c     path to forcing file
      forcpath = trim(indir)//'forcing_'//trim(scenario)//'.dat'

c     open forcing file
      open(iforcpath,file=forcpath,status='old')
      write (0,902) trim(forcpath)
 902  format ('forcing file: ',A)

c     find file length
      nin = 0
      do
 905    read(iforcpath,*,err=905,end=906) frecord(1)
        nin = nin + 1
      enddo
 906  rewind(iforcpath)


      allocate(forcing(nin+1,nforc))

c     read forcing array
      i=1
      do
 903    read (iforcpath,*,err=903,end=904) (frecord(j), j=1,nforc)
        do j=1,nforc
          if (abs(frecord(j)-NAinput).lt.1d-3)then
            forcing(i,j)=NA
          elseif (j.eq.jaCO2) then
            forcing(i,j)=frecord(j)*ppmtoGt
          else
            forcing(i,j)=frecord(j)
          endif
        enddo
        i=i+1
      enddo
 904  close(iforcpath)

      end
