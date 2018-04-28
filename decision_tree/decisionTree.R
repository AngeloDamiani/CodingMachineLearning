rm(list=ls())
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

##################### MATH FUNCTIONS ######################################

gini <- function(rows){
  nrows = nrow(rows)
  already_seen = vector()
  impurity = 1
  
  label_index = ncol(rows)
  for (label in 1:nrows){
    current_label = rows[label, label_index]
    if(!(current_label %in% already_seen)){
      lbl_count = sum(rows[,label_index] == current_label)
      impurity = impurity - (lbl_count/nrows)^2
      already_seen = c(already_seen, current_label)
    }
  }
  impurity
}

information_gain <- function(uncertainty, left_partition, right_partition){
  nright = nrow(right_partition)
  nleft = nrow(left_partition)
  ntotal = nleft + nright
  uncertainty - (nleft/ntotal)*gini(left_partition) - (nright/ntotal)*gini(right_partition)
}

###################### QUESTION DEFINITION ##################################

Question <- setRefClass("Question",
   fields = list(var = "numeric", point = "ANY"),
   methods = list(
     match = function(sample) {
       val = sample[var]
       if(is.numeric(point)){
         result = val >= point 
       }
       else{
         result = val == point
       }
       result
     }
   )
)

####################### TREE ELEMENTS ########################################

Node <- setRefClass("Node",
    fields = list()
)

QuestionNode <- setRefClass("QuestionNode",
  fields = list(question = "Question", left_son = "Node", right_son = "Node"),
  contains = c("Node")
)

Leaf <- setRefClass("Leaf",
  fields = list(solution = "ANY"),
  contains = c("Node")
)

###################### TREE BUILDING FUNCTIONS ###############################

split <- function(dataset, question){
  true_partition = vector()
  false_partition = vector()
  for (row in 1:nrow(dataset)){
    if (question$match(dataset[row,]) == TRUE){
      true_partition = rbind(true_partition, dataset[row,])
    }
    else{
      false_partition = rbind(false_partition, dataset[row,])
    }
  }
  partitions = list(true_partition, false_partition)
}

get_best_splitting_question <- function(dataset){
  
  best_question = NULL
  current_uncertainty = gini(dataset)
  max_gain = 0
  for (clmn in 1:(ncol(dataset)-1)){
    for (row in 1:nrow(dataset)){
      new_quest = Question(var=clmn, point=dataset[row,clmn])
      splitting = split(dataset, new_quest)
      true_rows = splitting[[1]]
      false_rows = splitting[[2]]
      
      if (length(true_rows) == 0 | length(false_rows) == 0) next
      
      gain = information_gain(current_uncertainty, true_rows, false_rows)
      if (gain >= max_gain){
        max_gain = gain
        best_question = new_quest
      }
    }
  }
  best_question
}

decision_tree_building <- function(dataset){
  result = NULL
  impurity = gini(dataset)
  if(impurity == 0){
    result = Leaf(solution=dataset[1,ncol(dataset)])
  }
  else{
    best_question = get_best_splitting_question(dataset)
    splitting = split(dataset, best_question)
    true_branch = splitting[[1]]
    false_branch = splitting[[2]]
    
    left_branch = decision_tree_building(true_branch)
    right_branch = decision_tree_building(false_branch)
    result = QuestionNode(question=best_question, left_son=left_branch, right_son=right_branch)
  }
  result
}

classify <- function(node, sample){
  result = NULL
  if (class(node)[[1]] == "Leaf"){
    result = node$solution
  }
  else{
    if(node$question$match(sample)){
      result = classify(node$left_son, sample)
    }
    else{
      result = classify(node$right_son, sample)
    }
  }
  result
}

################### MAIN ################################################################

data <- read.csv(file="./irisdataset.data", header=FALSE, sep=",")

dataset = vector()
for(i in 1:(ncol(data))){
  dataset = cbind(dataset, data[[i]])
}

tree = decision_tree_building(dataset)

# Three samples has been removed from iris dataset and put here

test1 = c(5.2,3.4,1.4,0.2) # "1" expected (Iris Setosa)
test2 = c(5.7,2.8,4.1,1.3) # "2" expected (Iris Versicolor)
test3 = c(7.9,3.8,6.4,2.0) # "3" expected (Iris Virginica)

print(classify(tree, test1))
print(classify(tree, test2))
print(classify(tree, test3))
