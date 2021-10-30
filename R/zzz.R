#' load packages that required
#' 
.onLoad = function(libname, pkgname) {
    ############## packages required ##############

    library(MCMCpack)
    library(mvtnorm)
    library(ellipse)
    library(coda)
    library(Matrix)
    library(Rtsne)
    library(gtools)
    library(foreach)
    library(doParallel)
    library(doSNOW)
    library(snow)
    library(lattice)
    library(MASS)
    library(bayesm)
    library(robustbase)
    library(chron)
    library(mnormt)
    library(schoolmath)
    library(RColorBrewer)

    #############################################
}

.flashLoad = function() {
    .onLoad(NULL, NULL);
} 
