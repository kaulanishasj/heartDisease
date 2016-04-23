cleveland_clean <- read.csv("C:/Users/Susrutha/Desktop/CMU/Spring 2016/Data Pipeline/Project/cleveland_clean.csv")
hungarian_clean <- read.csv("C:/Users/Susrutha/Desktop/CMU/Spring 2016/Data Pipeline/Project/hungarian_clean.csv")
long.beach.va_clean <- read.csv("C:/Users/Susrutha/Desktop/CMU/Spring 2016/Data Pipeline/Project/long-beach-va_clean.csv")
switzerland_clean <- read.csv("C:/Users/Susrutha/Desktop/CMU/Spring 2016/Data Pipeline/Project/switzerland_clean.csv")

cleveland_clean$datasource <- "cleveland"
hungarian_clean$datasource <- "hungarian"
long.beach.va_clean$datasource <- "long_beach_va_clean"
switzerland_clean$datasource <- "switzerland"

aggregate_data <- rbind(cleveland_clean, hungarian_clean)
aggregate_data <- rbind(aggregate_data, long.beach.va_clean)
aggregate_data <- rbind(aggregate_data, switzerland_clean)

#write.csv(aggregate_data, "aggregate_data.csv", row.names = FALSE)

#library(rattle)
#rattle()

# Remove variables marked as "REMOVE" in Data attributes trimming
aggregate_data$id <- NULL
aggregate_data$ccf <- NULL
aggregate_data$painloc <- NULL
aggregate_data$painexer <- NULL
aggregate_data$relrest <- NULL
aggregate_data$pncaden <- NULL
aggregate_data$smoke <- NULL
aggregate_data$proto <- NULL
aggregate_data$rldv5 <- NULL
aggregate_data$restckm <- NULL
aggregate_data$exerckm <- NULL
aggregate_data$restef <- NULL
aggregate_data$restwm <- NULL
aggregate_data$exeref <- NULL
aggregate_data$exerwm <- NULL
aggregate_data$thalsev <- NULL
aggregate_data$thalpul <- NULL
aggregate_data$earlobe <- NULL
aggregate_data$diag <- NULL
aggregate_data$ramus <- NULL
aggregate_data$om2 <- NULL
aggregate_data$lvx1 <- NULL
aggregate_data$lvx2 <- NULL
aggregate_data$cathef <- NULL
aggregate_data$junk <- NULL
aggregate_data$name <- NULL

# Removing attributes based on information from uci website ###
aggregate_data$lvf <- NULL
aggregate_data$lvx3 <- NULL
aggregate_data$lvx4 <- NULL
aggregate_data$lvf <- NULL
aggregate_data$dummy <- NULL

# Removed 31 variables until this point

for(i in c(1:ncol(aggregate_data))){
  for(j in c(1:nrow(aggregate_data))){
    if(aggregate_data[j,i] == -9){
      aggregate_data[j,i] <- NA
    }
  }
}

#write.csv(aggregate_data, "aggregate_data_trimmed_attr.csv", row.names = FALSE)

library(VIM)
aggr_plot <- aggr(aggregate_data, col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, 
                  labels=names(aggregate_data), cex.axis=.7, gap=3)

missing_data <- aggr_plot$missings
missing_data$percent_missing <- missing_data$Count/nrow(aggregate_data)
missing_data <- missing_data[order(missing_data$percent_missing, decreasing = TRUE),]

write.csv(missing_data, "missing_values_viz.csv", row.names = FALSE)

library(ggplot2)
qplot(y = missing_data$percent_missing[18:50],
      x = missing_data$Variable[18:50],
      main = "Distribution of columns with more than 10% missing values",
      xlab = "",
      ylab = "Missing values percentage") +
  geom_bar(fill = "steelblue", stat = "identity", width = 0.40) +
  theme(plot.title = element_text(face = "bold", size = 24)) +
  theme(axis.title = element_text(size = 18))+
  theme(axis.text = element_text(size = 18))

plot(aggregate_data_trimmed_attr$chol)
plot(aggregate_data$sex)
plot(aggregate_data$cp)
plot(aggregate_data_trimmed_attr$oldpeak)


aggregate_data_trimmed_attr <- aggregate_data
###################### Imputing missing values #########################
# Replacing missing values in 'restecg' with most frequently occuring variable
# This is because the values taken by this variable act like categorical in nature
aggregate_data_trimmed_attr$restecg[which(is.na(aggregate_data_trimmed_attr$restecg) == TRUE)] <- 
  as.numeric(names(table(aggregate_data_trimmed_attr$restecg)[which(table(aggregate_data_trimmed_attr$restecg) == 
                                                     max(table(aggregate_data_trimmed_attr$restecg)))]))

# Replacing missing values in 'chol' with standard deviation to induce minimum bias
aggregate_data_trimmed_attr$chol[which(is.na(aggregate_data_trimmed_attr$chol) == TRUE)] <- 
  sd(aggregate_data_trimmed_attr$chol, na.rm = TRUE)

# Replacing missing values in 'trestbps' with standard deviation to induce minimum bias
aggregate_data_trimmed_attr$trestbps[which(is.na(aggregate_data_trimmed_attr$trestbps) == TRUE)] <- 
  sd(aggregate_data_trimmed_attr$trestbps, na.rm = TRUE)

# Replacing missing values in 'fbs' with most commonly occuring value
aggregate_data_trimmed_attr$fbs[which(is.na(aggregate_data_trimmed_attr$fbs) == TRUE)] <- 
  as.numeric(names(table(aggregate_data_trimmed_attr$fbs)[which(table(aggregate_data_trimmed_attr$fbs) == 
                                                              max(table(aggregate_data_trimmed_attr$fbs)))]))

# Replacing missing values in 'thalach' with standard deviation to induce minimum bias
aggregate_data_trimmed_attr$thalach[which(is.na(aggregate_data_trimmed_attr$thalach) == TRUE)] <- 
  sd(aggregate_data_trimmed_attr$thalach, na.rm = TRUE)

# Replacing missing values in 'exang' with most commonly occuring value
aggregate_data_trimmed_attr$exang[which(is.na(aggregate_data_trimmed_attr$exang) == TRUE)] <- 
  as.numeric(names(table(aggregate_data_trimmed_attr$exang)[which(table(aggregate_data_trimmed_attr$exang) == 
                                                              max(table(aggregate_data_trimmed_attr$exang)))]))

# Replacing missing values in 'oldpeak' with standard deviation to induce minimum bias
aggregate_data_trimmed_attr$oldpeak[which(is.na(aggregate_data_trimmed_attr$oldpeak) == TRUE)] <- 
  sd(aggregate_data_trimmed_attr$oldpeak, na.rm = TRUE)

############### Add to prediction dataset from here #####################

# Replacing missing values in 'htn' with most commonly occuring value
aggregate_data_trimmed_attr$htn[which(is.na(aggregate_data_trimmed_attr$htn) == TRUE)] <- 
  as.numeric(names(table(aggregate_data_trimmed_attr$htn)[which(table(aggregate_data_trimmed_attr$htn) == 
                                                                    max(table(aggregate_data_trimmed_attr$htn)))]))

# Replacing missing values in 'dig' with most commonly occuring value
aggregate_data_trimmed_attr$dig[which(is.na(aggregate_data_trimmed_attr$dig) == TRUE)] <- 
  as.numeric(names(table(aggregate_data_trimmed_attr$dig)[which(table(aggregate_data_trimmed_attr$dig) == 
                                                                  max(table(aggregate_data_trimmed_attr$dig)))]))

# Replacing missing values in 'prop' with most commonly occuring value
aggregate_data_trimmed_attr$prop[which(is.na(aggregate_data_trimmed_attr$prop) == TRUE)] <- 
  as.numeric(names(table(aggregate_data_trimmed_attr$prop)[which(table(aggregate_data_trimmed_attr$prop) == 
                                                                  max(table(aggregate_data_trimmed_attr$prop)))]))

# Replacing missing values in 'nitr' with most commonly occuring value
aggregate_data_trimmed_attr$nitr[which(is.na(aggregate_data_trimmed_attr$nitr) == TRUE)] <- 
  as.numeric(names(table(aggregate_data_trimmed_attr$nitr)[which(table(aggregate_data_trimmed_attr$nitr) == 
                                                                   max(table(aggregate_data_trimmed_attr$nitr)))]))

# Replacing missing values in 'pro' with most commonly occuring value
aggregate_data_trimmed_attr$pro[which(is.na(aggregate_data_trimmed_attr$pro) == TRUE)] <- 
  as.numeric(names(table(aggregate_data_trimmed_attr$pro)[which(table(aggregate_data_trimmed_attr$pro) == 
                                                                   max(table(aggregate_data_trimmed_attr$pro)))]))

# Replacing missing values in 'diuretic' with most commonly occuring value
aggregate_data_trimmed_attr$diuretic[which(is.na(aggregate_data_trimmed_attr$diuretic) == TRUE)] <- 
  as.numeric(names(table(aggregate_data_trimmed_attr$diuretic)[which(table(aggregate_data_trimmed_attr$diuretic) == 
                                                                  max(table(aggregate_data_trimmed_attr$diuretic)))]))

# Replacing missing values in 'thaldur' with standard deviation to induce minimum bias
aggregate_data_trimmed_attr$thaldur[which(is.na(aggregate_data_trimmed_attr$thaldur) == TRUE)] <- 
  sd(aggregate_data_trimmed_attr$thaldur, na.rm = TRUE)

# Replacing missing values in 'thalrest' with standard deviation to induce minimum bias
aggregate_data_trimmed_attr$thalrest[which(is.na(aggregate_data_trimmed_attr$thalrest) == TRUE)] <- 
  sd(aggregate_data_trimmed_attr$thalrest, na.rm = TRUE)

aggr_plot <- aggr(aggregate_data_trimmed_attr, col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, 
                  labels=names(aggregate_data), cex.axis=.7, gap=3)


plot(table(aggregate_data_trimmed_attr$thaldur))
plot(table(aggregate_data_trimmed_attr$thalrest))

################## Data frame to be used for prediction ####################
prediction_dataset <- aggregate_data[,c("age", "sex", "cp", "trestbps",
                                                     "chol", "fbs", "restecg", "thalach", 
                                                     "exang", "oldpeak", 
                                                     "htn", "dig", "prop", "pro",
                                                     "nitr", "diuretic", "thaldur", "thalrest",
                                                     "datasource", "num")]
prediction_dataset <- aggregate_data_trimmed_attr
set.seed(12)
training_indices <- sample(c(1:nrow(prediction_dataset)), 
                           size = round(0.9*nrow(prediction_dataset)))
testing_data <- prediction_dataset[setdiff(c(1:nrow(prediction_dataset)), training_indices), ]

training_data <- prediction_dataset[sample(training_indices, 0.8*length(training_indices)), ]
crossvalidation_data <- prediction_dataset[setdiff(training_indices, 
                                                   sample(training_indices, 0.8*length(training_indices))), ]


write.csv(training_data, "training_data.csv", row.names = FALSE)
write.csv(crossvalidation_data, "crossvalidation_data.csv", row.names = FALSE)
write.csv(testing_data, "C:/Users/Susrutha/Desktop/CMU/Spring 2016/Data Pipeline/Project/testing_data_final.csv", row.names = FALSE)


aggr_plot <- aggr(prediction_dataset, col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, 
                  labels=names(aggregate_data), cex.axis=.7, gap=3)

train_data <- rbind(training_data, crossvalidation_data)
all_data <- rbind(train_data, testing_data)

write.csv(all_data, "C:/Users/Susrutha/Desktop/CMU/Spring 2016/Data Pipeline/Project/all_clean_data_final.csv", row.names = FALSE)
write.csv(train_data, "C:/Users/Susrutha/Desktop/CMU/Spring 2016/Data Pipeline/Project/train_data_final.csv", row.names = FALSE)


all_clean_data$datasource[which(all_clean_data$datasource == "hungarian")] <- "Budapest, Hungary"
all_clean_data$datasource[which(all_clean_data$datasource == "switzerland")] <- "Zurich, Switzerland"
all_clean_data$datasource[which(all_clean_data$datasource == "cleveland")] <- "Cleveland, USA"
all_clean_data$datasource[which(all_clean_data$datasource == "long_beach_va_clean")] <- "California, USA"


train_data <- aggregate_data
train_data$datasource <- NULL
train_data$num <- ifelse(train_data$num == 0, yes = 0, no = 1)

train.lm <- lm(num ~. , data = train_data)
train.lm.truncated <- stepAIC(train.lm, direction="backward", trace = 0)


library(VIM)

outlier_analysis$datasource <- NULL

aggr_plot <- aggr(outlier_analysis, col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, 
                  labels=names(outlier_analysis), cex.axis=.7, gap=3)


############# MISSING VALUES IMPUTATION ###############
library(mice)
impute_dataset <- prediction_dataset
missing_value_pattern <- md.pattern(impute_dataset)

aggr_plot <- aggr(impute_dataset, col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, 
                  labels=names(impute_dataset), cex.axis=.7, gap=3)

missing_values_pattern <- as.data.frame(md.pattern(impute_dataset))
write.csv(missing_values_pattern, "C:/Users/Susrutha/Desktop/CMU/Spring 2016/Data Pipeline/Project/missing_values_pattern.csv", row.names = TRUE)
blah <- which(is.na(impute_dataset$pro) == TRUE)
blah2 <- which(is.na(impute_dataset$nitr) == TRUE)
blah3 <- which(is.na(impute_dataset$thalach) == TRUE)
blah4 <- intersect(blah, blah2)
blah5 <- intersect(blah3, blah4)

blah6 <-  which(is.na(impute_dataset$exang) == TRUE)
blah7 <- intersect(blah5, blah6)

blah8 <- which(is.na(impute_dataset$thaldur) == TRUE)
blah9 <- intersect(blah7, blah8)

blah10 <- which(is.na(impute_dataset$prop) == TRUE)
blah11 <- intersect(blah9, blah10)

blah12 <- which(is.na(impute_dataset$dig) == TRUE)
blah13 <- intersect(blah11, blah12)

blah14 <- which(is.na(impute_dataset$diuretic) == TRUE)
blah15 <- intersect(blah13, blah14)

blah16 <- which(is.na(impute_dataset$thalrest) == TRUE)
blah17 <- intersect(blah15, blah16)

blah18 <- which(is.na(impute_dataset$trestbps) == TRUE)
blah19 <- intersect(blah17, blah18)

blah20 <- which(is.na(impute_dataset$oldpeak) == TRUE)
blah21 <- intersect(blah19, blah20)

blah22 <- which(is.na(impute_dataset$chol) == FALSE)
blah23 <- intersect(blah21, blah22)

blah24 <- which(is.na(impute_dataset$htn) == FALSE)
blah25 <- intersect(blah23, blah24)

aggregate_data_trimmed_attr <- impute_dataset[-blah25,]
write.csv(aggregate_data_trimmed_attr, "C:/Users/Susrutha/Desktop/CMU/Spring 2016/Data Pipeline/Project/final_data_with_missing.csv", row.names = FALSE)


## Substituting outlier data points
prediction_dataset$thalrest[which(prediction_dataset$thalrest < 20)] <- mean(prediction_dataset$thalrest) 

prediction_dataset$trestbps[which(prediction_dataset$trestbps == 0)] <- mean(prediction_dataset$trestbps) 






