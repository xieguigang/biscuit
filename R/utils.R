
############## helper functions ##############

centralize.mat <- function(M){
    n <- nrow(M)
    Q <- matrix(-1/n, nrow=n, ncol = n)
    diag(Q) <-  diag(Q)+1
    M <- Q %*% M %*% Q
    M
}

######
center_colmeans <- function(x) {
    xcenter = colMeans(x)
    x - rep(xcenter, rep.int(nrow(x), ncol(x)))
}

######
norm_vec <- function(x) sqrt(sum(x^2))

######

getmode <- function(v) {
    uniqv <- unique(v)
    uniqv[which.max(tabulate(match(v, uniqv)))]
}
######

######### Projecting X

project.data <- function(data, dim_data){

    S <- data %*% t(data)
    Sc <- centralize.mat(S)
    Sc <- 0.5*(Sc + t(Sc))
    eig <- eigen(Sc)
    w <- which(eig$values>0.01)
    if(length(w) < dim_data){
        w <- c(1:dim_data)
    }

    sq_diag <- diag(sqrt((eig$values)[w]))
    sq_diag[is.na(sq_diag)] <- 0.001;
    data_pca <- (eig$vectors)[,w] %*% sq_diag

}

############


######### Projecting X

fiedler.vector <- function(data){

    s.eigen <- eigen(data) # the eigenvalues are in decreasing order so just extract the 2nd last one.
    return(s.eigen$vectors[,(ncol(data) -1)])

}

############


####Fix the number of parallel subprocesses

sub_batch <- function(num_gene_batches){
    flag1 <- TRUE
    if(num_gene_batches==1){
        num_gene_sub_batches <- 1
    }else{
        if(num_gene_batches %% 10 == 0 | (is.prim(num_gene_batches) & (num_gene_batches > 10)) ){
            num_gene_sub_batches <- 10
        }else{
            while(flag1==TRUE){
                for(count1 in 9:1){
                    if(num_gene_batches %% count1 ==0){
                        num_gene_sub_batches <- count1;
                        flag1 <- FALSE
                        break
                    }
                }
            }
        }
    }
    return(sub_batch <- num_gene_sub_batches)
}

##########MDS scaling

mds.tau <- function(H)
{
    n <- nrow(H)
    P <- diag(n) - 1/n
    return(-0.5 * P %*% H %*% P)
}

color_palette = function() {
    ###### getting distinguishable colours for clusters #####
    ##ref: http://stackoverflow.com/questions/15282580/how-to-generate-a-number-of-most-distinctive-colors-in-r
    ##

    qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
    col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals))) #len = 74
    num_col <- 40
    #pie(rep(1,num_col), col=(col_vector[1:num_col]))
    col_palette <- col_vector[1:num_col]; # or sample if you wish
    col_palette;
}
