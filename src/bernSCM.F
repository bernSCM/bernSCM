#include "control.inc"


#if LandTdep
      subroutine tdep_prop(pp,s,T,q)
c     Wrapper that updates propagators for T-dependent IRF coefficients

c     local variables

      include 'general.inc'
      include 'numerics.inc'
      type(PIRF) :: p,pp        !IRF coefficients
      type(SIRF) :: s           !IRF sensitivities
      type(Prop) :: q           !propagators to be updated
      real*8 T                  !Temperature perturbation (K)

      logical exceed            !exceeded parametrization range
      character*4 Tmaxc           !auxiliary

      save exceed

      p=pp !temporary variable to calculate propagators

c     check parametrization range
      if(T>s%Tmax.and..not.exceed)then
        write(Tmaxc,'(F3.1)') s%Tmax
        write(0,*) "warning: temperature parametrization range of IRF "//trim(p%name)//" exceeded ("//trim(Tmaxc)//"K)."
        exceed=.true.
      endif

      p%weight(1:p%nscale+1)=p%weight(1:p%nscale+1)*exp(s%weight(1:p%nscale+1)*T)
      p%weight(1:p%nscale+1)=p%weight(1:p%nscale+1)/sum(p%weight(1:p%nscale+1))

      p%tscale(1:p%nscale)=p%tscale(1:p%nscale)*exp(-s%tscale(1:p%nscale)*T) !infinite tscale not changed

      call propagators(p,q)
      
      end subroutine tdep_prop
#endif


      subroutine propagators(p,q)
c     calculate coefficients for numerical solution (propagators)

      include 'general.inc'
      include 'functions.inc'
      include 'numerics.inc'
      type(PIRF) :: p           !IRF coefficients
      type(Prop) :: q           !propagators to be updated
c     local vars
      integer i                 !counter
#if !linear
c     calculate propagators
      do i=1,p%nscale
        if (p%tscale(i)<= tequil) then !equilibrated
          q%propf(i)=p%weight(i)*p%tscale(i) !not use adapted weights (they are for finite tscale)
          q%propm(i)=0d0
        else
          q%propf(i)=p%weight(i)*p%tscale(i)*(1d0-exp(-dt/p%tscale(i)))
          q%propm(i)=exp(-dt/p%tscale(i))
        endif
      enddo
      q%propf(p%nscale+1)=dt*p%weight(p%nscale+1)
      q%propm(p%nscale+1)=1d0

#elif linear
c     calculate propagators
      do i=1,p%nscale
        q%propf(i)=p%weight(i)*p%tscale(i)*(dt - p%tscale(i)*(1d0 - exp(-dt/p%tscale(i))))/dt
        q%propfo(i)=p%weight(i)*p%tscale(i)*(1d0 - exp(-dt/p%tscale(i))) - q%propf(i)
      enddo
      q%propf(p%nscale+1)  = p%weight(p%nscale+1)*dt/2d0
      q%propfo(p%nscale+1) = p%weight(p%nscale+1)*dt - q%propf(p%nscale+1)
    
      q%propm(1:p%nscale) = exp(-dt/p%tscale(1:p%nscale))
      q%propm(1+p%nscale) = 1d0

#endif
      q%nscale=p%nscale

      end subroutine propagators




      subroutine setforcing(n)

      include 'general.inc'
      include 'io.inc'
      include 'functions.inc'

      integer n                 !time counter

      Temp(n)=interpol(
     $     time(n),
     $     forcing(itime(n),jtime),
     $     forcing(itime(n)+1,jtime),
     $     forcing(itime(n),jTemp),
     $     forcing(itime(n)+1,jTemp)
     $     )
      RFnC(n)=interpol(
     $     time(n),
     $     forcing(itime(n),jtime),
     $     forcing(itime(n)+1,jtime),
     $     forcing(itime(n),jRFnC),
     $     forcing(itime(n)+1,jRFnC)
     $     )
      RFB(n)=interpol(
     $     time(n),
     $     forcing(itime(n),jtime),
     $     forcing(itime(n)+1,jtime),
     $     forcing(itime(n),jRFB),
     $     forcing(itime(n)+1,jRFB)
     $     )
      mA(n)=interpol(
     $     time(n),
     $     forcing(itime(n),jtime),
     $     forcing(itime(n)+1,jtime),
     $     forcing(itime(n),jaCO2),
     $     forcing(itime(n)+1,jaCO2)
     $     )
      eCO2(n)=interpol(
     $     time(n),
     $     forcing(itime(n),jtime),
     $     forcing(itime(n)+1,jtime),
     $     forcing(itime(n),jeCO2),
     $     forcing(itime(n)+1,jeCO2)
     $     )
      fB(n)=interpol(
     $     time(n),
     $     forcing(itime(n),jtime),
     $     forcing(itime(n)+1,jtime),
     $     forcing(itime(n),jfB),
     $     forcing(itime(n)+1,jfB)
     $     )

c     work out budget closure case

      if(.not.(mA(n)==NA).or.fB(n)==NA) then
c     if(fB(n)==NA) then !this condition doesn't work for change of budget closure
        Fbudget=.true.
      else
        Fbudget=.false.
      endif
      if(.not.(Temp(n)==NA).or.RFB(n)==NA) then
c     if(RFB(n)==NA) then !this condition doesn't work for change of budget closure
        RFbudget=.true.
      else
        RFbudget=.false.
      endif

c     check budget cases (setting RF_CO2 is not implemented)

      if(eCO2(n)==NA.or.RFnC(n)==NA)then
        stop 'eCO2 and RF_nonC must always be set, use budget_RF and budget_sink to solve for RF/emissions'
      endif


      CO2budget=.false. !default value (CO2budget only for T → CO2)
      if(.not.(RFbudget.or.Fbudget))then !CT
!     nothing to do
      elseif(RFbudget.and..not.Fbudget)then !CR
!     not checking mA, allow overwriting CO2
        if(Temp(n)==NA)then
          print*, 'glob_temp_dev not set when solving for budget_RF at year ',time(n)
          stop
        endif
      elseif(.not.RFbudget.and.Fbudget)then !ET
        if(mA(n)==NA)then
          print*, 'CO2_atm not set when solving for budget_sink at year ',time(n)
          stop
        endif
      elseif(RFbudget.and.Fbudget)then !disambiguation
        if(Temp(n)==NA)then
          print*, 'glob_temp_dev not set when solving for budget_RF at year ',time(n)
          stop
        endif
        if(mA(n)==NA)then       !CE
          CO2budget=.true.      !Solve CO2 from T constraint
        endif
      endif


      end subroutine setforcing




      subroutine steppulse(
c     function to advance the integration of a tracer
     $     n                    ! time index
     $     ,f                   ! flux to mixed layer
     $     ,mk                  ! boxes/tracer pools (input/output)
     $     ,m                   ! total tracer (output)
     $     ,q                   ! propagators
     $     ,x                   ! Variable-specific multiplier/conversion factor
     $     )

      include 'general.inc'
      include 'numerics.inc'
      type(Prop) :: q

      real*8
     $     f(ntime)
     $     ,mk(nscalemax+1)
     $     ,m
     $     ,x
     $     ,sdecay(nscalemax+1)

      integer n,j

      do j=1,q%nscale+1
        mk(j)=mk(j)*q%propm(j) + f(n)*q%propf(j)*x 
#if linear
        mk(j)=mk(j) + f(n-1)*q%propfo(j)*x
#endif  
      enddo
      m=sum(mk(1:q%nscale+1))

      end subroutine steppulse




      subroutine timestep(n)


      include 'general.inc'
      include 'functions.inc'
      include 'parLand.inc'
      include 'parOcean.inc'
      include 'numerics.inc'
c     local variables
      integer n                 !time index
      real*8
     $     Tcom                 !committed temperature change (K)
     $     ,mLcom               !committed Land C (Gt)
     $     ,mScom               !committed ocean mixed layer C (Gt)      
     $     ,e                   !anthropogenic emissions (Gt/yr)
#if implicitO
     $     ,nennerU,nennerW     !macro for implicit solution
     $     ,dmAO,mAeq           !dmA/dmS, mA∞(mS)
#endif
#if implicitL
     $     ,dfNPPdmA            !dNPP/dmA
     $     ,nennerV             !macro for implicit solution
     $     ,dfNPP               !change in fNPP (Gt/yr)
#endif

!     - local variable defined a bit differently from output variable

c     (committed) temperature calculation
#if implicitO
      fH(n)=fH(n-1)             !ocean heat uptake, const. flux commitment
      call steppulse(n ,fH ,Tempk ,Tcom ,O ,OmT)
#else
      call steppulse(n-1 ,fH ,Tempk ,Tcom ,O ,OmT) !approximate current flux last (small dt)
#endif

c     ocean heat uptake
      if (RFbudget) then
c     update heat uptake (const. flux commitment)
        fH(n)=fH(n-1) + (Temp(n)-Tcom)/(OmT*sum(O%propf(1:O%nscale+1)))
c     update Tempk!
        Tempk(1:O%nscale+1)=Tempk(1:O%nscale+1) + (fH(n)-fH(n-1))*O%propf(1:O%nscale+1)*OmT 
c     current RF (W/m²)
        RF(n)=fH(n)/(Aoc/Ofrac/Peta) + Temp(n)/T2x*RF2x 

        if(CO2budget)then
c     solve for atmospheric CO2
          mA(n) = RFeqCO2mA(RF(n)-RFnC(n))
        endif

      endif
      
#if LandTdep
      if(Tdep)then              !update temperature-dependent parameters
        if(RFbudget)then
          call tdep_prop((Pland),Sland,(Temp(n-1)+Temp(n))/2d0,L) !use actual T
        else
          call tdep_prop((Pland),Sland,(Temp(n-1)+Tcom)/2d0,L) !use commited T
        endif
      endif
#endif

c     land C exchange
      if(Fbudget)then
c     solve for net C emissions
#if linear
c     (endyear value)
        if(RFbudget)then        !use actual T
          fNPP(n)=npp(mA(n),Temp(n),.false.)
        else                    !use commited T
          fNPP(n)=npp(mA(n),Tcom,.false.)
        endif
#else
c     (midyear value)
        if(RFbudget)then
          fNPP(n)=npp((mA(n)+mA(n-1))/2d0,(Temp(n)+Temp(n-1))/2d0,.false.) 
        else
          fNPP(n)=npp((mA(n)+mA(n-1))/2d0,Temp(n-1),.false.)
        endif
#endif
      else
c  anthro emissions
        e=(eCO2(n)+eCO2(n-1))/2d0 - (fB(n)+fB(n-1))/2d0

#if implicitL
c     auxiliary parameters
c     commitment step with previous flux
        fNPP(n)=fNPP(n-1)
        dfNPPdmA= npp(mA(n-1),Temp(n-1),.true.)
c        dfNPPdmA= npp(mA(n-1),Tcom,.true.) !Using Tcom has practically no effect
        nennerV=(dfNPPdmA*sum(L%propf(1:L%nscale+1))+1d0)
#endif
      endif

#if implicitL
      call steppulse(n ,fNPP ,mLk ,mLcom ,L ,1d0) !commited land C
#else
      if (Fbudget) then
        call steppulse(n,fNPP,mLk,mLcom,L,1d0) !commited land C
      else
        call steppulse(n-1,fNPP,mLk,mLcom,L,1d0) !approximated land C using previous flux
      endif
#endif

#if implicitO
c     commitment step with current flux=0
      fO(n)=0
c  aux. parameters
c      dmAO=dpCO2s(mS(n-1)*OmC,Temp(n-1),.true.)*ppmtoGt*OmC
c      mAeq=(dpCO2s(mS(n-1)*OmC,Temp(n-1),.false.)+co2_atm0)*ppmtoGt
      dmAO=dpCO2s(mS(n-1)*OmC,Tcom,.true.)*ppmtoGt*OmC !Using Tcom is more precise
      mAeq=(dpCO2s(mS(n-1)*OmC,Tcom,.false.)+co2_atm0)*ppmtoGt !Using Tcom is more precise
      nennerU=(KgAoc*dmAO*sum(O%propf(1:O%nscale+1))+1d0)
      nennerW=dt*KgAoc      
#else
      fO(n)=fasC(mA(n-1),dpCs(n-1))
#if lagged
      fO(n)=lag*fO(n-1) + (1-lag)*fO(n) !lag flux
#endif
#endif

      call steppulse(n,fO,mSk,mScom,O,1d0) !committed ocean mixed layer C

#if implicitL
      if (Fbudget) then
        mL(n)=mLcom             !committed=actual value
      else
c     implicit step for flux change (zeroE commitment for ocean):

        dfNPP = dfNPPdmA/(nennerU*nennerV+nennerW)
     $       *(
     $       mL(n-1) - mLcom + dt* e
     $       +dt*KgAoc*(
     $       + mAeq - mA(n-1) 
     $       +dmAO*(mScom - mS(n-1) + sum(O%propf(1:O%nscale+1))*((mL(n-1) - mLcom)/dt +e))
     $       ))

        mL(n) = dfNPP*sum(L%propf(1:L%nscale+1)) + mLcom
      endif  
#else
      mL(n)=mLcom !committed=actual value
#endif


#if implicitO
c     implicit ocean step
      if(Fbudget)then
        fO(n)=KgAoc*(mA(n) - mAeq - dmAO*(mScom - mS(n-1)))/nennerU
      else
        fO(n)=KgAoc/(nennerU + nennerW)*(mA(n-1) -mAeq - dmAO*(mScom -mS(n-1)) - (mL(n)-mL(n-1)) + dt*e) 
      endif

      mSk(1:O%nscale+1) = mSk(1:O%nscale+1) + fO(n)*O%propf(1:O%nscale+1)
      mS(n)=sum(mSk(1:O%nscale+1))
#else
      mS(n)=mScom !committed=actual value
#endif

c     total C budget
      if(.not.Fbudget)then
#if linear
        mA(n) = mA(n-1)+dt*(e - (fO(n-1)+fO(n))/2d0) - (mL(n)-mL(n-1)) !update atmo CO2
#else
        mA(n) = mA(n-1)+dt*(e - fO(n)) - (mL(n)-mL(n-1)) !update atmo CO2
#endif
      endif

      RFC(n)=RFco2(mA(n)) !update CO₂ RF

      if(.not.RFbudget)then
        RF(n)=RFC(n)+RFnC(n)+RFB(n) !update total RF (W/m²)

        if(T2x>0d0)then
#if implicitO
c     const flux commitment
          fH(n)=(RF(n) - RF2x*Tcom/T2x + fH(n-1)*OmT*sum(O%propf(1:O%nscale+1))*RF2x/T2x)
     $         /(RF2x/T2x*OmT*sum(O%propf(1:O%nscale+1))+Ofrac*Peta/Aoc)
          Tempk(1:O%nscale+1)=Tempk(1:O%nscale+1) + (fH(n)-fH(n-1))*O%propf(1:O%nscale+1)*OmT
          Temp(n)=sum(Tempk(1:O%nscale+1))
#else
          Temp(n)=Tcom          !actual=committed value
          fH(n)=fasT(RF(n),Temp(n)) !update ocean heat uptake
#endif
        else                    !exception for T2x=0
          fH(n)=0d0
          Temp(n)=0d0
          Tempk(:)=0d0
        endif

      endif

      fNPP(n)=npp(mA(n),Temp(n),.false.) !update NPP

      if(.not.Fbudget)then
c     update mLk with updated NPP
        mLk(1:L%nscale+1) = mLk(1:L%nscale+1) + (fNPP(n)-fNPP(n-1))*L%propf(1:L%nscale+1)
      endif
      dpCs(n)=dpCO2s(mS(n)*OmC,Temp(n),.false.) !update sea surface CO₂ pressure perturbation (ppm)

      end subroutine timestep
