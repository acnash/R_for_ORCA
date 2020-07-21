#'=============================================================
#'IR and Raman spectra plotting from ORCA output files.
#'This is not a package (yet). Source this file and then see getIRData() 
#'and getRamanData() function for example code. 
#'
#'Anthony Nash
#'University of Oxford
#'Initial release 21/07/2020
#'=============================================================

#' The user-facing function to retrieve all IR related data from the ORCA output. 
#' The returned data is then passed onto buildPlotSpectra, and in turn the result from 
#' buildPlotSpectra is passed into plotSpectra. The example provides a complete solution
#' to using the code. 
#'
#' @param fileStr A character vector to the ORCA output file. 
#'
#' @return A data.frame containing the raw spectra values. 
#' @export
#'
#' @examples
#' irFileDataONEDF <- getIRData("M06_6-31G(d).OUT")
#' irFileDataTWODF <- getIRData("M06_6-311G++(d,p).OUT") 
#' spectraNames <- c("M06_6-31G(d)","M06_6-311G++(d,p)")
#' irSpectraObject <- buildPlotSpectra(irFileDataONEDF, irFileDataTWODF,
#'                                      spectraNames=spectraNames, mode="IR", 
#'                                      minLabelY=100)
#' plotSpectra(ramanSpectraObject)
getIRData <- function(fileStr) {
  if(missing(fileStr)) {
    stop("ORCA input file is missing in the argument list.")
  }
  #this is the user facing function
  
  fileData <- loadORCAOutputFile(fileStr, "IR")
  return(fileDate)
}


#' The user-facing function to retrieve all Raman related data from the ORCA output. 
#' The returned data is then passed onto buildPlotSpectra, and in turn the result from 
#' buildPlotSpectra is passed into plotSpectra. The example provides a complete solution
#' to using the code. 
#'
#' @param fileStr A character vector to the ORCA output file. 
#'
#' @return A data.frame containing the raw spectra values. 
#' @export
#'
#' @examples
#' ramanFileDataONEDF <- getRamanData("M06_6-31G(d).OUT")
#' ramanFileDataTWODF <- getRamanData("M06_6-311G++(d,p).OUT") 
#' spectraNames <- c("M06_6-31G(d)","M06_6-311G++(d,p)")
#' ramanSpectraObject <- buildPlotSpectra(ramanFileDataONEDF, ramanFileDataTWODF,
#'                                        spectraNames=spectraNames, mode="RAMAN", 
#'                                        minLabelY=100)
#' plotSpectra(ramanSpectraObject)
getRamanData <- function(fileStr) {
  if(missing(fileStr)) {
    stop("ORCA input file is missing in the argument list.")
  }
  #this is the user facing function
  fileData <- loadORCAOutputFile(fileStr, "RAMAN")
  return(fileData)
  
}

#' Plots the collection of IR or Raman spectra provided in a SpectraObject. This 
#' is the last user step in displaying the data. 
#'
#' @param spectraObject A collection of Raman or IR spectra.
#'
#' @return
#' @export
#'
#' @examples
#' plotSpectra(ramanSpectraObject)
plotSpectra <- function(spectraObject) {
  if(missing(spectraObject)) {
    stop("The spectraObject argument was missing.")
  }
  
  if(is.null(spectraObject)) {
    stop("NULL object provided to plotSpectra. Please check the result of buildPlotSpectra.")
  }
  
  plot(spectraObject[[1]])
}

#' Builds the spectrum plot and also returns the raw data as an S3 SpectraObject. See the
#' functions getIRData() and getRamanData() for working exampes. 
#'
#' @param ... Individual spectra data generated using getIRData() or getRamanData().
#' @param spectraNames A character vector of names for the plot legend. This must be the same length as the
#' number of individual spectra provided.
#' @param mode Must be either "IR" or "RAMAN".
#' @param minLabelY A basic Y > N indicator to direct the labelling of peaks. Default is 0. The peaks
#' are not labeled if the default value (0) is used. 
#'
#' @return A named SpectraObject object. The first element is the ggplot2 object and
#' the second element is the raw data as a data.frame of N obs and 4 variables: Mode, 
#' Freq, Y-value (IR/Raman dependent), Spectra. The SpectraObject can be passed into plotSpectra.  
#' @export
#'
#' @examples See getIRData() and getRamanData()
buildPlotSpectra <- function(..., spectraNames=NULL, mode=NULL, minLabelY=0) {
  IR <- "IR"
  RAMAN <- "RAMAN"
  spectraList <- list(...)
  
  #check where minLabelY makes sense
  if(minLabelY < 0) {
    stop(paste("minLabelY was", minLabelY, "please provide a value of >= 0."))
  }
  
  #check whether the spectra entries are all data.frames
  checkSpectraList <- sapply(spectraList, function(x) is.data.frame(x))
  if(sum(checkSpectraList) != length(spectraList)) {
    stop("At least one of the spectra data variables is invalid. Supply each spectra data variable as a data.frame.")
  }
  
  #define default names if ones haven't been provided
  if(length(spectraNames) != length(spectraList)) {
    print("Defining new spectrum names.")
    spectraNames <- sapply(1:length(spectraList), function(x) paste0("Spectra_",x))
  }
  
  for(i in 1:length(spectraList)) {
    spectraList[[i]] <- cbind(spectraList[[i]], Spectra=spectraNames[i])
  }
  
  spectraDF <- do.call("rbind", spectraList)
  set.seed(42)
  
  if(mode == IR) {
    gg <- ggplot2::ggplot(spectraDF, ggplot2::aes(x=Freq, y=Transmission, fill=Spectra, color=Spectra)) +
      ggplot2::geom_bar(stat = "identity") + ggplot2::xlab("Freq (cm**-1)") + ggplot2::ylab("T**2") + 
      ggplot2::scale_x_reverse() + ggplot2::scale_y_reverse() + ggplot2::theme_bw() + labs(fill="") + labs(color="") +
      ggplot2::theme(legend.position="bottom", axis.text=ggplot2::element_text(size=12),axis.title=ggplot2::element_text(size=14)) 
    if(minLabelY > 0) {
    gg <- gg + ggrepel::geom_label_repel(data=spectraDF[spectraDF$Transmission>=minLabelY,], ggplot2::aes(x=Freq, y=Transmission, label=Transmission,
                             fill = factor(Spectra)), color = 'black', size = 2.5)
    }  
    
  } else if(mode == RAMAN) {
    
    gg <- ggplot2::ggplot(spectraDF, ggplot2::aes(x=Freq, y=Activity, fill=Spectra, color=Spectra)) +
      ggplot2::geom_bar(stat = "identity") + ggplot2::xlab("Raman shift / (cm**-1)") + ggplot2::ylab("Intensity") + 
      ggplot2::theme_bw() + labs(fill="") + labs(color="") +
      ggplot2::theme(legend.position="bottom", axis.text=ggplot2::element_text(size=12),axis.title=ggplot2::element_text(size=14)) 
    if(minLabelY > 0) {
      gg <- gg + ggrepel::geom_label_repel(data=spectraDF[spectraDF$Activity>=minLabelY,], ggplot2::aes(x=Freq, y=Activity, label=Activity, 
                            fill = factor(Spectra)), color = 'black', size = 2.5)                                                                                               
    }
    
  } else {
    stop("Unknown mode!")
  }
  
  returnList <- list(Plot=gg, Data=spectraDF)
  class(returnList) <- "SpectraObject"
  return(returnList)
}



#' Loads and parses the ORCA output file. The user does not play with this function. 
#'
#' @param fileStr A character string to the ORCA output file. 
#' @param mode A character string or either "IR" or "RAMAN".
#'
#' @return A data.frame of the raw spectrum data.
#' @export
#'
#' @examples See getIRData() and getRamanData() for examples.
loadORCAOutputFile <- function(fileStr, mode) {
  print(paste("Looking for", mode, "spectrum."))
  RAMAN_KEY <- "RAMAN SPECTRUM"
  IR_KEY <- "IR SPECTRUM"
  IR <- "IR"
  RAMAN <- "RAMAN"
  
  forRaman <- FALSE
  forIR <- FALSE
  
  lineCounter <- 0
  
  modeVector <- 0
  freqVector <- 0
  activityVector <- 0
  
  resultDF <- NULL
  
  #check whether the argument is a character string
  if(!is.character(fileStr)) {
    stop("ORCA output file was not supplied as a character string.")
  }
  #check whether the file exits
  fileCheck <- file.exists(fileStr)
  if(isFALSE(fileCheck)) {
    stop(paste("The file", fileStr, "does not exist."))
  }
  #get the file size and inform the user
  fileSizeBytes <- file.size(fileStr)
  fileSizeMB <- fileSizeBytes*0.000001
  print(paste("The file", fileStr, "is", fileSizeMB,"MB in size."))
  
  con = file(fileStr, "r")
  while(TRUE) {
    #read in line and remove trailing/leading white space
    line <- trimws(readLines(con, n = 1))
    if(length(line) == 0) {
      break()
    }
    
    #if we've found the IR spectrum and we asked for it
    if(isTRUE(grepl(IR_KEY, line, fixed = TRUE)) && (mode == IR)) {
      forIR <- TRUE
      print("Found IR SPECTRUM")
      lineCounter <- 0
    }
    
    #if we've found the Raman spectrum and we asked for it
    if(isTRUE(grepl(RAMAN_KEY, line, fixed = TRUE)) && (mode == RAMAN)) {
      forRaman <- TRUE
      print("Found RAMAN SPECTRUM")
      lineCounter <- 0
    }
    
    #the fifth line from either IR SPECTRUM or RAMAN SPECTRUM will be the 6th vibration
    #the line count is always reset to 0 when either spectrum key is found (in either order)
    if(lineCounter >= 5 && (isTRUE(forIR) || isTRUE(forRaman))) {
      
      #Found the end of the spectrum data
      if(nchar(line)==0) {
        lineCounter <- 0
        #store all the data
        if(mode == IR) {
          resultDF <- data.frame(Mode=as.integer(modeVector), Freq=as.double(freqVector), Transmission=as.double(activityVector), stringsAsFactors = FALSE)
          break()
        } else if(mode == RAMAN) {
          resultDF <- data.frame(Mode=as.integer(modeVector), Freq=as.double(freqVector), Activity=as.double(activityVector), stringsAsFactors = FALSE)
          break()
        } else {
          stop("You really shouldn't be in here!")
        }
      }
      #dealing with the spectrum data lines
      splitLine <- strsplit(line, "\\s+")[[1]]
      modeVector[lineCounter-4] <- substr(splitLine[1],1,nchar(splitLine[1])-1) #get the mode number
      freqVector[lineCounter-4] <- splitLine[2]#get the freq number
      activityVector[lineCounter-4] <- splitLine[3]#get the mode number
    }
    
    lineCounter <- lineCounter + 1
    
  }
  
  close(con)
  
  if(is.null(resultDF)) {
    stop("Could not find either IR SPECTRUM or RAMAN SPECTRUM in the file.")
  }
  
  return(resultDF)
}

