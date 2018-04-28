rm(list=ls())

k = 10
samples = 100

plotlim = c(-4,4)

# Means generation
mk_bluex1 = rnorm(n=k, mean=1, sd=1)
mk_bluex2 = rnorm(n=k, mean=0, sd=1)
mk_blue = t(rbind(mk_bluex1, mk_bluex2)) 

mk_orangex1 = rnorm(n=k, mean=0, sd=1)
mk_orangex2 = rnorm(n=k, mean=1, sd=1)
mk_orange = t(rbind(mk_orangex1, mk_orangex2)) 

# Means picking to generate samples
mks_blue = mk_blue[sample(nrow(mk_blue),size=samples,replace=TRUE),]
mks_orange = mk_orange[sample(nrow(mk_orange),size=samples,replace=TRUE),]

# Blue samples generation
x_blue = vector()
for(row in 1:samples) {
  x_blue = c(x_blue, MASS::mvrnorm(n=1, mu=mks_blue[row,], Sigma = diag(2)/5))
}
dim(x_blue) = c(2,samples)
x_blue = t(x_blue)

# Orange samples generation
x_orange = vector()
for(row in 1:nrow(mks_orange)) {
  x_orange = c(x_orange, MASS::mvrnorm(n=1, mu=mks_orange[row,], Sigma = diag(2)/5))
}
dim(x_orange) = c(2,samples)
x_orange = t(x_orange)

# Merging of samples in a single vector
total_x = rbind(x_blue, x_orange)

# forecast initialization
forecast_blue_x = vector()
forecast_orange_x = vector()

# Initial test level (to select the distribution)
alpha0 = 0.05

# blue2orange identifies  the number of blue samples predicted as orange
# orange2blue viceversa
blue2orange = 0
orange2blue = 0

# Test evaluation, better explained in readme.md on github: 
# https://github.com/AngeloDamiani/CodingMachineLearning
for(i in 1:nrow(total_x)){
  alpha = alpha0/2
  
  x1isblue = FALSE
  x1isorange= FALSE
  
  x2isblue = FALSE
  x2isorange= FALSE
  
  x1 = total_x[i,1]
  x2 = total_x[i,2]
  
  x1alpha = alpha
  x2alpha = alpha
  
  repeat{
    
    if(((!x1isblue) & (!x1isorange)) | (x1isblue & x1isorange)){
      zalpha_x1_orange  = qnorm(1-x1alpha, mean=1, sd=1)
      z_alpha_x1_orange = qnorm(x1alpha, mean=1, sd=1)
      zalpha_x1_blue  = qnorm(1-x1alpha, mean=0, sd=1)
      z_alpha_x1_blue = qnorm(x1alpha, mean=0, sd=1)
    }
    
    if(((!x2isblue) & (!x2isorange)) | (x2isblue & x2isorange)){
      zalpha_x2_blue = qnorm(1-x1alpha, mean=1, sd=1)
      z_alpha_x2_blue = qnorm(x1alpha, mean=1, sd=1)
      zalpha_x2_orange = qnorm(1-x1alpha, mean=0, sd=1)
      z_alpha_x2_orange = qnorm(x1alpha, mean=0, sd=1)
    }
    
    if((x1 <= zalpha_x1_blue) | (x1>= z_alpha_x1_blue)){
      x1isblue = TRUE
    }
    if((x2 <= zalpha_x2_blue) | (x2 >= z_alpha_x2_blue)){
      x2isblue = TRUE
    }
    if((x1 <= zalpha_x1_orange) | (x1 >= z_alpha_x1_orange)){
      x1isorange = TRUE
    }
    if((x2 <= zalpha_x2_orange) | (x2 >= z_alpha_x2_orange)){
      x2isorange = TRUE
    }
    
    
    if((x1isblue & x2isblue) & !(x1isorange & x2isorange)){
      forecast_blue_x = rbind(forecast_blue_x, total_x[i,])
      if (i>100){
        orange2blue = orange2blue + 1
      }
      break
    }
    if((x1isorange & x2isorange) & !(x1isblue & x2isblue)){
      forecast_orange_x = rbind(forecast_orange_x, total_x[i,])
      if (i<=100){
        blue2orange = blue2orange + 1
      }
      break
    }
    
    
    if((x1isblue & x1isorange) | (!x1isblue & !x1isorange)){
      if(!x1isblue & !x1isorange){
        x1alpha = x1alpha - 0.0001
      }
      else{
        x1alpha = x1alpha + 0.0001
      }
      x1isblue = x1isorange = FALSE
    }
    if((x2isblue & x2isorange) | (!x2isblue & !x2isorange)){
      if(!x2isblue & !x2isorange){
        x1alpha = x1alpha - 0.0001
      }
      else{
        x1alpha = x1alpha + 0.0001
      }
      x2isblue = x2isorange = FALSE
    }

  }
  if (i%%10==0)
    {print(i)}
}


# Original samples plot
plot(x_blue,col="blue", xlim=plotlim,ylim=plotlim)
points(x_orange, pch=4, col="orange")

# Forecast samples plot
plot(forecast_blue_x,col="blue", xlim=plotlim,ylim=plotlim)
points(forecast_orange_x, pch=4, col="orange")

# Errors
errors = blue2orange + orange2blue
print("Prediction error:")
print(errors)
sprintf("Error rate: %s %%", errors/2)

