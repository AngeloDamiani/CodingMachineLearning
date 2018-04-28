# CodingMachineLearning
In this repository I put all coded Machine Learning Algorithms I did. [Just for practice]
____________________

### Decision Tree
Is a classical decision tree building in R. It filters questions using information gain for splitting branches and measure  impurity using Gini impurity.

Three kinds of node are defined:
* Node: common interface for different nodes
* QuestionNode: decision node that divide the classification in two branches
* Leaf: contains the answer for a classification

Questions are modeled as objects containing index and value of the splitting variable. 

The used training set is the [Iris Dataset](https://archive.ics.uci.edu/ml/datasets/iris).
&nbsp;
_________________________

### Bayesian Classifier (for a specific case)
As proved in [Elements of Statistical Learning](https://www.amazon.com/Elements-Statistical-Learning-Prediction-Statistics/dp/0387848576/ref=pd_lpo_sbs_14_img_0?_encoding=UTF8&psc=1&refRID=DAQ91A4V0TX92WAGKW1Y), to better statistically predict a categorical variable using a 0-1 loss function is to choose the label g that maximize 

<div style="text-align:center"><img src="http://latex.codecogs.com/gif.latex?P%28g%20%7C%20X%20%3D%20x%29"/></div>

Where X is a random variable and x is the vector assumed in the sample.
So in this code there are 200 two-dimensionals values generated as follows:
* 10 "blue" elements "m_blue" are generated from the multivariate normal distribution N([0,1]', I).
* 10 "orange" elements "m_orange" are generated from N([1,0]', I).
* 100 m_blue are selected (with replace) and used to create a sample "X_blue" from the multivariate normal distribution N(m_blue, I/5). So at the end of this point there are 100 samples X labeled as blue.
* 100 m_orange are selected to do the same. So there are other 100 samples X tagged as orange.

Now, given a random X, the code try to guess what is the most probable distribution from which is generated X.
A single vector X can be written as 

<div style="text-align:center"><img src="http://latex.codecogs.com/gif.latex?X%20%3D%20%5Bx_1%2C%20x_2%5D"/></div>

Since the two features are independent of each other, the code calculate (for each individual of the sample) two confidence interval for both the variables of each distribution. The confidence interval is initialized with an alpha that covers the 95% of the one-dimensional distribution. If a feature of the individual is in both distributions confidence intervals (of that feature), the intervals are cut reducing the alpha of 0.1%. After that will be checked again the belonging of the feature to those new intervals. In another case, if a feature of the individual is not in any interval, those are enlarged increasing alpha of 0.1%. This process will stop when just one multivariate distribution have both the features of the individual in both its confidence intervals. 

The error is still high (a mean of 60 bad classification on 200) and this method can only work on independent features.

















