      real*8
     $     NPP0,                !preindustrial (potential natural) NPP (Gt/yr)
     $     fert                 !Fertilization Coefficient
      
      parameter(
     $     NPP0 = 60d0,
     $     fert = 0.287d0
     $     )

      real*8 m0,dNPP

      type(DOCU) :: DocuNPP=DOCU(
c     component
     $     "#\n# NPP function for Bern 4 Box biosphere"       
c     authors
     $     ,""                  
c     references
     $     ,"#\n# - I.G. Enting, T.M.L. Wigley, and M. Heimann, 1994: Future emissions and concentrations of"
     $     //"\n# carbon dioxide: Key ocean/atmosphere/land analyses, Tech. Rep. 31, CSIRO"
     $     //"\n# Atmos. Res., Melbourne, Victoria."
     $     //"\n# - D.J. Schimel, D. Alves, I.G. Enting, M. Heimann, F. Joos, D. Raynaud, T. Wigley, 1996:"
     $     //"\n# CO2 and the carbon cycle, in IPCC Second Scientific Assessment of Climate Change,"
     $     //"\n# ed. by Houghton, pp. 76-86, Cambridge Univ. Press, NY."
c     description
     $     ,"#\n# NPP depends logarithmically on atmospheric CO2 (Enting et al., 1994) with the" !description
     $     //"\n# scale factor beta=0.287 determined from C budget closure (Schimel et al. 1996) for 1980-1990."
     $     )
 
