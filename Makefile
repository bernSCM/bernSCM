# Pulse-response model Makefile
############################
# Compiler and options

profile=gfortran
#profile=pgf90

ifeq ($(profile),pgf90)
FCOM=pgf90
CPPFLAGS        = -E
COMPFLAGS       = -Mextend -Mdalign -Kieee -Ktrap=fp -O2 -r8
#COMPFLAGS       = -Mextend -Mdalign -Kieee -Ktrap=fp -O2 -r8 -Mprof=lines # to analyze computation time by subroutines
DEBUGFLAGS	= -g -O0 -Mextend -Mbounds -Minfo -Minform,inform -Kieee -Ktrap=fp -r8 
endif


ifeq ($(profile),gfortran)
FCOM=gfortran
CPPFLAGS        = -cpp -E -ffixed-line-length-132 #-P
#COMPFLAGS       =    -ffixed-line-length-132 -fbackslash -ffpe-trap=invalid,zero,overflow,underflow -fdefault-real-8 -fno-align-commons -O2
COMPFLAGS       =    -ffixed-line-length-132 -fbackslash -ffpe-trap=invalid,zero,overflow,underflow -fno-align-commons -O1
DEBUGFLAGS	= -g     -ffixed-line-length-132  -fbackslash -ffpe-trap=invalid,zero,overflow,underflow -fdefault-real-8 -fno-align-commons -fbounds-check # -O0  -fdump-core -fbacktrace
endif


####################
## general config ##
####################

# name of executable
EXE = bernSCM
ifeq ($(profile),gfortran)
MAINO = ./src/bernSCM-main.o #gfortran needs this
MAINDO = ./src/bernSCM-main.do #gfortran needs this
endif
ARCHIVES= ./src/bernSCM.a

# Export variables that are needed by Makefiles in the subdirectories (called below)
export FCOM CPPFLAGS COMPFLAGS DEBUGFLAGS #LIBS

# Targets
# -------
standard:
	 $(MAKE) -C src
	 $(FCOM) -o $(EXE) $(COMPFLAGS) $(MAINO) $(ARCHIVES) $(LIBS)
# code for debugging:
debug: 
	$(MAKE) debug -C src
	$(FCOM) -o $(EXE) $(DEBUGFLAGS) $(MAINDO) $(ARCHIVES) $(LIBS)

# Build only the lpj.a library (used by the Bern3D Makefile)
pulselib:
	$(MAKE) -C src

# clean: remove exe and .o and .do files
.PHONY: clean
clean:
	-rm $(EXE)
	$(MAKE) clean -C src

#EOF
