      real*8
     $     bufferT             !ocean chemistry T-dependence (Takahashi 1993)

      parameter(
     $     bufferT=0.0423d0
     $     )

      type(DOCU) :: DocuOchem=DOCU(
c     component
     $     "#\n# Ocean chemistry parametrization"       
c     authors
     $     ,""                  
c     references
     $     ,"\n# - F. Joos, M. Bruno, R. Fink, T. F. Stocker, U. Siegenthaler, C. Le Quere, and"
     $     //"\n# J. L. Sarmiento, 1996: An efficient and accurate representation of complex oceanic"
     $     //"\n# and biospheric models of anthropogenic carbon uptake. Tellus, 48B:397-417"
c     description
     $     ,"#\n# Nonlinear dependence of buffer factor on DIC after Joos et al. (1996)." !description
     $     //"\n# Impact of sea surface warming on carbonate chemistry after Takahashi (1993)."
     $     )
