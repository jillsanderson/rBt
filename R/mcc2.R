#' mcc2
#'
#' This function is based on the \code{\link{maxCladeCred}}
#' in \code{phangorn}, and it finds the maximum clade 
#' crebility tree given a list of trees. 
#' 
#' 
#'
#' @param phy List of \code{multiPhylo} trees
#' @param annot Inform whether \code{mcc2} should annotate on
#'              the mcc tree using \code{"freq"} frequencies or
#'              \code{"pos"} posterior probabilities.
#' @return mcc tree \code{phylo} object
#' @seealso \code{\link{maxCladeCred}} \code{\link{prop.part}}
#' @importFrom fastmatch fmatch
#' @export mcc2
#' @examples
#' path <- system.file("data/trees/", package="rBt")
#' trs <- mcc.trees2multi(path)
#' mcctr <- mcc2(trs)
#' 
#' 
#' 
#' 
#' 

mcc2 <- function(phy, annot="pos"){
    if (length(grep("posterior", names(phy[[1]]))) == 1)
        annot="pos"
    else
        annot="freq"
    pp <- prop.part(phy)
    pplabel <- attr(pp, "labels")
    m <- max(attr(pp, "number"))
    nb <- log(attr(pp, "number")/m)
    L <- length(phy)
    res <- numeric(L)
    for (i in 1:L){
        tmp <- phangorn:::checkLabels(phy[[i]], pplabel)
        ppi <- prop.part(tmp)
        indi <- fmatch(ppi, pp)
        if (any(is.na(indi))) 
            res[i] <- -Inf
        else res[i] <- sum(nb[indi])
    }
    k <- which.max(res)
    message("Clade credibility (log): ",res[k])
    tr <- phy[[k]]
    tr$clade.credibility <- res[k]
    ppk <- prop.part(tr)
    pmt <- matrix(NA,ncol=L, nrow=length(ppk))
    for (i in 1:L){
        ppi <- prop.part(phy[[i]])
        indi <- fmatch(ppk, ppi)
        if (annot == "pos")
            pmt[!is.na(indi),i] <- phy[[i]]$posterior[!is.na(indi)]
        else if (annot == "freq")
            pmt[!is.na(indi),i] <- 1
        else 
            stop("annot needs to be either \"pos\" or \"freq\"")
    }
    mcp <- rowSums(pmt, na.rm=TRUE)/L
    if (annot == "pos")
            tr$MCposterior <- mcp
    else if (annot == "freq")
            tr$freq <- mcp
    return(tr)
}
