# List of source code files:
SOURCES=bernSCM-main.F bernSCM-init.F bernSCM-output.F bernSCM.F bernSCM-readforcing.F functions.F

# List of build dependencies (Makefiles, include files etc.):
GENINC=numerics.inc
DEPEND=Makefile functions.inc general.inc io.inc par*.inc control.inc *.finc $(GENINC)

# Generate list of .o and .do files from SOURCES
OBJS=$(SOURCES:.F=.o)
DEBUGOBJS=$(SOURCES:.F=.do)
FORS=$(SOURCES:.F=.for)

# Archive file names
ARCHIVE=bernSCM.a

# Targets
# -------
# standard source code: (depends on object files)
standard:	$(OBJS)
	chmod -w $(FORS)
	-rm $(ARCHIVE)
	ar r $(ARCHIVE) $(OBJS)

# code for debugging:
debug:	$(DEBUGOBJS)
	chmod -w $(FORS)
	-rm $(ARCHIVE)
	ar r $(ARCHIVE) $(DEBUGOBJS)

# default rules (.F -> .for -> .o/.do)
# ------------
%.for:	%.F $(DEPEND)
	rm -f $*.for
	$(FCOM) $(CPPFLAGS) $*.F > $*.for
	sed -i '/^\#/d' $*.for #optional clean-up

%.inc:	%.inc.F #$(DEPEND)
	$(FCOM) $(CPPFLAGS) $*.inc.F > $*.inc
	sed -i '/^\#/d' $*.inc #optional clean-up

$(OBJS): %.o: %.for $(DEPEND)
	$(FCOM) -c -o $@ $(COMPFLAGS) $*.for

$(DEBUGOBJS): %.do: %.for
	$(FCOM) -c -o $@ $(DEBUGFLAGS) $*.for

# don't delete the intermediate *.for files
.SECONDARY:     $(SOURCES:.F=.for)

# clean: remove .for, .o, .do, and .stb files
.PHONY: clean
clean:
	-rm -f *.for *.o *.do *.stb *.s $(GENINC)
	rm $(ARCHIVE)



#EOF
