rm(list=ls())
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

############# MATH SUPPORT FUNCTIONS ##########################

# R's "cov" could have been useful but I wanted to 
# code the covariance matrix building on my own.

cov_mat = function(X){
  mat = matrix(, nrow = ncol(X), ncol = ncol(X))
  N = nrow(X)
  for(i in 1:ncol(X)){
    for(j in 1:ncol(X)){
      mu_i = mean(X[,i]) 
      mu_j = mean(X[,j])
      cov_ij = 0
      for(row in 1:N){
        cov_ij = cov_ij + (X[row,i]-mu_i)*(X[row,j]-mu_j)
      }
      cov_ij = (1/(N-1))*cov_ij
      mat[i,j] = cov_ij
      mat[j,i] = cov_ij
    }
  }
  mat
}

############# PRINCIPAL COMPONENT ANALYSIS ###################

pca = function(X, dim){
  X = scale(X, center = TRUE, scale = TRUE)
  ei = eigen(cov_mat(X))
  # eigenvalues are already reverse-sorted 
  eigenvalues = ei$values
  eigen_vectors = ei$vectors
  
  result = list()
  
  result[[1]] = X%*%eigen_vectors[,1:dim]
  result[[2]] = eigen_vectors
  result
}


reduce = function(x, alphas){
  # Here we suppose alphas as column vector and x as row vector/matrix 
  x%*%alphas
}

######################  MAIN  #########################################


data("iris")

last_var = 4
dim = 2


ds <- log(iris[, 1:last_var])
species = iris[, 5]
var_names = names(ds)
ds = data.matrix(ds)

pca_res = pca(ds, dim)
alphas = pca_res[[2]]
alpha_m = alphas[,1:dim]

projection = pca_res[[1]]

# PROJECTION PLOTTING

library(plotly)

setosa = vector()
virginica = vector()
versicolor = vector()

markersize = 8

for(i in 1:nrow(projection)){
  if(species[i]=="setosa"){
    setosa = rbind(setosa, projection[i,])
  }
  if(species[i]=="versicolor"){
    versicolor = rbind(versicolor, projection[i,])
  }
  if(species[i]=="virginica"){
    virginica = rbind(virginica, projection[i,])
  }
}


p <- plot_ly() %>% 
     add_trace(x = setosa[,1], 
               y = setosa[,2],
               type="scatter", 
               mode="markers", 
               name="Iris Setosa",
               marker = list(size = markersize, color = 'rgb(255, 182, 193)')
     )%>% 
     add_trace(x = virginica[,1], 
               y = virginica[,2],
               type="scatter", 
               mode="markers", 
               name="Iris Virginica",
               marker = list(size = markersize, color = 'rgb(0, 184, 230)')
     )%>% 
     add_trace(x = versicolor[,1], 
               y = versicolor[,2],
               type="scatter", 
               mode="markers", 
               name="Iris Versicolor",
               marker = list(size = markersize, color = 'rgb(0, 204, 0)')
     )


vectors = reduce(diag(last_var), alpha_m)

for(i in 1:nrow(vectors)){
  p = p %>% add_trace(x = c(0, vectors[i,1]) , y=c(0,vectors[i,2]),name=var_names[i], mode = "lines", type = 'scatter')
}
