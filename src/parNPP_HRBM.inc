
      real*8
     $     NPP0                 !preindustrial (potential natural) NPP (Gt/yr)

      parameter(
     $     NPP0 = 41.73282d0
     $     )

      type(DOCU) :: DocuNPP=DOCU(
c     component
     $     "#\n# HRBM NPP parametrization"       
c     authors
     $     ,""                  
c     references
     $     ,""
c     description
     $     ,"#\n# NPP is parametrized as product of two functions fitted to" !description
     $     //"\n# a series of HRBM simulations, one for temperature dependence,"
     $     //"\n# and one for CO2 dependence."
     $     )
