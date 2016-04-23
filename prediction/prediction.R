
library(rpart)
library(rpart.plot)
library(pROC)

get_pred_rpart <- function(train, test) {
  train.rpart <- rpart(num ~ .,
                       data=train_data,
                       method="class",
                       parms=list(split="information"),
                       control=rpart.control(usesurrogate=0, 
                                             maxsurrogate=0))
  pred.results <- predict(train.rpart, newdata=test)[,2]
  results <- data.frame(prediction = pred.results, true_output = test[,ncol(test)])
  return(results) 
}

get_metrics <- function(pred.df, cutoff = 0.5) {
  
  # Assign class based on the cutoff value
  actual.prob <- pred.df[,1]
  
  for(i in 1:nrow(pred.df)) {
    if(pred.df[i,1] <= cutoff) {
      pred.df[i,1] <- 0
    } else {
      pred.df[i,1] <- 1
    }
  }
  
  
  # True Positives
  tp <- length(which(pred.df[,1] == 1 & pred.df[,2] == 1))
  
  # True Negatives
  tn <- length(which(pred.df[,1] == 0 & pred.df[,2] == 0))
  
  # False Positives
  fp <- length(which(pred.df[,1] == 1 & pred.df[,2] == 0))
  
  # False Negatives
  fn <- length(which(pred.df[,1] == 0 & pred.df[,2] == 1))
  
  # True Positive Rate
  tpr <- tp/(tp + fn)
  
  # False Positive Rate
  fpr <- fp/(fp + tn)
  
  # True Negative Rate
  tnr <- tn/(tn + fp)
  
  # False Negative Rate
  fnr <- fn/(fn + tp)
  
  # Accuracy
  acc <- (tp + tn)/(nrow(pred.df))
  
  # Precision
  precision <- tp/(tp + fp)
  
  # Recall
  recall <- tp/(tp + fn)
  
  # F-Measure
  fmeasure = 2*precision*recall/(precision + recall)
  
  # Creating a dataframe with all error metrics
  results <- data.frame(cutoff = cutoff,
                        tpr = tpr,
                        fpr = fpr,
                        tnr = tnr,
                        fnr = fnr,
                        acc = acc)
  return(results)
}

do_cv_class <- function(df, num_folds, model_name) {
  
  # Randomly partitioning data into num_folds almost equal parts
  num.rows <- nrow(df)
  random.indices <- sample(1:nrow(df))
  numfold.indices <- vector(mode = "list", length = num_folds)
  reminder.val <- nrow(df)%%num_folds  # Number of data points that would be left out 
  # Each data fold would have a 'start' and 'end' value
  start <- 1
  step.size <- floor(nrow(df)/num_folds)  # Step size 
  for(i in 1:num_folds) {
    # Equally assign the points that would be left out to the first few data folds
    if(i <= reminder.val) {
      end <- start + step.size 
    } else {
      end <- start + step.size - 1
    }
    numfold.indices[[i]] <- random.indices[start:end]
    start <- end + 1
  }
  
  #   k <- 0
  #   # Calling the appropriate model
  #   # Extracting 'k' from the passed model name ONLY if extracted first letter is a numeric
  #   k <- as.numeric(gsub("([0-9]+).*$", "\\1", model_name))
  #   if(!is.na(k)) {
  #     model_name <- gsub("\\d+", "k", model_name)
  #   }
  
  # Pasting "get_pred_" to call the appropriate model
  actual.model.name <- eval(parse(text = paste("get_pred_", model_name, sep = "")))
  
  # Initialize a dataframe to store results
  results <- data.frame()
  
  for(i in 1:num_folds) {
    train <- df[-numfold.indices[[i]], ]  # Containing all rows except for the ones used for testing
    test <- df[numfold.indices[[i]], ]  # Contains test data with last column being outcome variable
    #    print(test)
    # Calling the corresponding model function with train and test data
    #    if(is.na(k)) {
    pred.results <- actual.model.name(train, test)
    #    } else {
    #      pred.results <- actual.model.name(train, test, k)
    #    }
    results <- rbind(results, pred.results)
  }
  
  return(results)
  
}


results <- do_cv_class(train_data, 5, "rpart")
errors <- get_metrics(results)

#####

train_data <- read.csv("C:/Users/Susrutha/Desktop/CMU/Spring 2016/Data Pipeline/Project/train_data.csv")
train_data$datasource <- NULL
train_data$num <- ifelse(train_data$num == 0, yes = 0, no = 1)

testing_data <- read.csv("C:/Users/Susrutha/Desktop/CMU/Spring 2016/Data Pipeline/Project/testing_data.csv")
testing_data$datasource <- NULL
testing_data$num <- ifelse(testing_data$num == 0, yes = 0, no = 1)
test <- testing_data[,-ncol(testing_data)]

train.rpart <- rpart(num ~ .,
                     data=train_data,
                     method="class",
                     parms=list(split="information"),
                     control=rpart.control(usesurrogate=0, 
                                           maxsurrogate=0))
pred.prob.results <- predict(train.rpart, newdata=test)[,2]
pred.results <- predict(train.rpart, newdata=test, type = "class")
results <- data.frame(prediction = pred.prob.results, true_output = testing_data[,ncol(testing_data)])
errors <- get_metrics(results)
rpart.plot(train.rpart)

tree.roc <- roc(results[,2], results[,1], auc = T, ci = T, plot = TRUE)
plot.roc(tree.roc, legacy.axes = T,
         ci = TRUE, ci.type = "bars",
         xlab = "False Positive Rate", ylab = "True Positive Rate",
         col = "red")


cut_off.errors <- data.frame()
for(i in 0:100){
  cut_off.errors <- rbind(cut_off.errors, get_metrics(results, i/100))
}
plot(cut_off.errors$fpr, cut_off.errors$tpr, type = "b")
# cutoff 0.2 gives optimal ROC point
errors <- get_metrics(results, 0.2)


# Regression
lm.model <- lm(num ~ ., data = train_data)
anova(lm.model)





