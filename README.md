# R_for_ORCA
R code to visualise spectra from the ORCA output file. 

Written by Anthony Nash PhD (inception: 21/07/200). 

Please reference this page along with myself if you make use of these R functions. 

These R functions were just a little bit of fun to tie my experience of using R with an attempt at forever improving my understanding of theoretical biophysics and computational chemistry. 

See the code for more information but in essense to make use of the functions:

#===============================================================================
source("IR_spectra_code.R")

#Compare two raman spectra
ramanFileDataONEDF <- getRamanData("M06_6-31G(d).OUT")
ramanFileDataTWODF <- getRamanData("M06_6-311G++(d,p).OUT") 
spectraNames <- c("M06_6-31G(d)","M06_6-311G++(d,p)")
ramanSpectraObject <- buildPlotSpectra(ramanFileDataONEDF, ramanFileDataTWODF,
                                        spectraNames=spectraNames, mode="RAMAN", 
                                        minLabelY=100)
plotSpectra(ramanSpectraObject)

#===============================================================================
#Compare two IR spectra
irFileDataONEDF <- getIRData("M06_6-31G(d).OUT")
irFileDataTWODF <- getIRData("M06_6-311G++(d,p).OUT") 
spectraNames <- c("M06_6-31G(d)","M06_6-311G++(d,p)")
irSpectraObject <- buildPlotSpectra(irFileDataONEDF, irFileDataTWODF,
                                     spectraNames=spectraNames, mode="IR", 
                                     minLabelY=100)
plotSpectra(ramanSpectraObject)
#===============================================================================
