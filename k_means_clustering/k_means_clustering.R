rm(list=ls())
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

################## MATH SUPPORT FUNCTIONS ###############################################
euclidean_distance = function(x,y){
  sum = 0
  for(i in 1:length(x)){
    sum = sum + (x[i]-y[i])^2
  }
  sqrt(sum)
}

################## CLUSTER OBJECT DEFINITION ############################################

Cluster <- setRefClass("Cluster",
  fields = list(elements = "ANY", centroid = "ANY"),
  methods = list(
    recompute_centroid = function() {
      
      # Centroid not in distribution
      close_centroid = colSums(elements)/nrow(elements)
    
      #Computation of the closest centroid to the theorical one
      closest_distance = Inf
      for(row in 1:nrow(elements)){
        ele = elements[row,]
        distance = euclidean_distance(ele, close_centroid)
        if(distance < closest_distance){
          closest_distance = distance
          centroid <<- ele
        }
      }
    },
    add_element = function(point) {
      elements <<- rbind(elements, point)
    }
  )
)

################## CLUSTERIZATION ALGORITHM #############################################

clusterize = function(dataset, k){
  original_centroids = dataset[sample(nrow(dataset), size=k, replace=FALSE),]
  cluster_list = list()
  # Clusters initialization
  for(centroid in 1:k){
    cluster_list[[centroid]] = Cluster(elements=vector(), centroid=original_centroids[centroid,])
  }
  
  moved = TRUE
  i = 1
  
  while(moved == TRUE){
    print(i)
    moved = FALSE
    old_centroids = vector()
    new_centroids = vector()
    for(cluster in 1:length(cluster_list)){
      cluster_list[[cluster]]$elements = vector()
      old_centroids = rbind(old_centroids, cluster_list[[cluster]]$centroid)
    }
    
    # Computation of the closest cluster and adding of the single row to it
    for(row in 1:nrow(dataset)){
      closest_cluster = NULL
      closest_distance = Inf
      for(clsr in 1:k){
       distance = euclidean_distance(dataset[row,], old_centroids[clsr,])
       if (distance < closest_distance){
         closest_distance = distance
         closest_cluster = cluster_list[[clsr]]
       }
       closest_cluster$add_element(dataset[row,])
      }
    }
    
    for(cluster in 1:k){
      cluster_list[[cluster]]$recompute_centroid()
      new_centroids = rbind(new_centroids, cluster_list[[cluster]]$centroid)
    }
    
    moved = TRUE
    if(all(new_centroids == old_centroids)){
      moved = FALSE
    }
    i = i+1
  }
  cluster_list
}




################### MAIN ################################################################

data <- read.csv(file="./s1.txt", header=FALSE, sep=";")

dataset = vector()
for(i in 1:(ncol(data))){
  dataset = cbind(dataset, data[[i]])
}

k = 15

clusters = clusterize(dataset, k)

#colors = sample(1:150, k, replace=FALSE)
colors = c("#e6194b","#3cb44b","#ffe119","#0082c8",
           "#f58231","#911eb4","#46f0f0","#808080",
           "#000080","#ffd8b1","#808000","#800000",
           "#fffac8","#aa6e28","#008080","#6190ab",
           "#afafaf","#8ad18c","#abcdef","#123456")

plot(clusters[[1]]$elements[,1],clusters[[1]]$elements[,2], col=colors[1], pch=20)
for(i in 2:k){
  points(clusters[[i]]$elements[,1],clusters[[i]]$elements[,2], col=colors[i], pch=20)
}
