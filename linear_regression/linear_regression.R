rm(list=ls())
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

##############################################################################

library(MASS)
library(plotly)

linear_regression = function(X, y){
  beta = ginv(t(X)%*%X) %*% t(X) %*% y
}

predict = function(x, beta){
  y = (c(1, x))%*%beta
}

#############################################################################

data <- read.csv(file="./retard.txt", header=FALSE, sep=";")
dataset = vector()
for(i in 1:(ncol(data))){
  dataset = cbind(dataset, data[[i]])
}

ones = rep(1, nrow(dataset))
X_original = dataset[,1:(ncol(dataset)-1)]

X = cbind(ones, X_original)
y = dataset[,ncol(dataset)]

beta = linear_regression(X,y)

y_hat = X%*%beta

data_hat = cbind(X_original, y_hat)


p = plot_ly(x = data_hat[,1], y = data_hat[,2], z = data_hat[,3], type="mesh3d", opacity=1) %>% 
  add_trace(x = data_hat[,1], y = data_hat[,2], z = y, mode = "markers", type = "scatter3d", 
            marker = list(size = 2, color = "red", symbol = 200))



p