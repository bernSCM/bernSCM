
      subroutine initialize()
      
#include "control.inc"
      include 'general.inc'
      include 'io.inc'
      include 'functions.inc'

      include 'parLand.inc'
      include 'parNPP.inc'
      include 'parOcean.inc'

      Include 'numerics.inc'

      real*8 tin(nin+1)         !input time
      integer i,j               !counters

c     check setup

#if linear && tequil>0
      stop "Equilibrated time steps not implemented for linear"
#elif (linear && !((implicitO || implicitL) == 1))
      stop "linear scheme only implicit"
#endif

      tin=forcing(:,jtime)

c     get time dimension
      ntime=int((tin(nin)-tin(1))/dt+1d-6)+1

      allocate(time(ntime),itime(ntime))
      allocate(Temp(ntime),RFnC(ntime),RFC(ntime),RFB(ntime),RF(ntime),fH(ntime))
      allocate(mA(ntime),dpCs(ntime),mS(ntime),mL(ntime),eCO2(ntime),fB(ntime),fNPP(ntime),fO(ntime))

c     construct model time
      j=1
      do i=1,ntime      
        time(i)=tin(1)+(i-1)*dt !model time
        do while(time(i)>tin(j+1)) 
          j=j+1
        enddo
        itime(i)=j              !corresponding index of forcing timeseries
      enddo

      
c     initialize variables
      RF(:)=0d0
      RFnC(:)=0d0
      RFC(:)=0d0
      RFB(:)=0d0
      fH(:)=0d0
      fB(:)=0d0
      dpCs(:)=0d0
      fO(:)=0d0
      mS(:)=0d0
      fNPP(:)=NPP0
      mL(:)=0d0

c     initialize propagators !(don't put inside propagators routine)
      L%nscale=0
      L%propm(1:nscalemax+1)=0d0
      L%propf(1:nscalemax+1)=0d0
      L%x=0d0

c     initialize propagators !(don't put inside propagators routine)
      O%nscale=0
      O%propm(1:nscalemax+1)=0d0
      O%propf(1:nscalemax+1)=0d0
      O%x=0d0

      call propagators(Pland,L)
      call propagators(Pocean,O)

c     initial Land C stock
      allocate(mLk(Pland%nscale+1))

      mLk(:)=0d0
      do i=1,Pland%nscale
        mLk(i)=(NPP0*Pland%weight(i)*Pland%tscale(i))
        mL(1)=mL(1)+mLk(i)
      enddo

c     initial ocean mixed layer C stock perturbation
      allocate(mSk(Pocean%nscale+1))
      mSk(:)=0d0
      mS(1)=0d0

c     initial ocean temperature perturbation
      allocate(Tempk(Pocean%nscale+1))
      Tempk(:)=0d0
      Temp(1)=0d0


      end subroutine initialize

