# R_for_ORCA
R code to visualise spectra from the ORCA output file. 

Written by Anthony Nash PhD (inception: 21/07/200). 

This is very much a personal-use pursuit but if you make use of these R functions please reference this page along with myself. 

## Introduction
These R functions were just a little bit of fun to tie my experience of using R with an attempt at forever improving my understanding of theoretical biophysics and computational chemistry. 

## Language dependencies
The code was written using R 4.0.1 (on a Windows 10 64 bit).

The following packages are required:
  * ggplot2 (developed using v. 3.3.2)
  * ggrepel (developed using v. 0.8.2)

## A quick example
The R functions will look for the single instance of "IR SPECTRUM" and "RAMAN SPECTRUM" in the ORCA output file. If these are not present the user is informed. 
The code work flow is quite basic:
1. Read in the raw Raman or IR data: `getRamanData()` or `getIRData()`.
2. Build the ggplot2 visuals and process the raw data: `buildPlotSpectra()`.
3. Visualise the spectra: `plotSpectra()`.

Consider the example of compraing the spectra of two IR and two Raman calculations:

```r
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
```
The peak value labels are assigned when a peak is greater than `minLabelY`. Labels can be turned off using `minLabelY=0`. Users can make unique adjustments to the ggplot2 object by retrieving the ggplot2 object found in the first element of the `irSpectraObject` data structure or by potting the raw spectrum data found in the second element.  

Plotting the IR data will produce:
![alt text](https://github.com/acnash/R_for_ORCA/blob/master/Two_IR.jpeg "2 IR spectra")
