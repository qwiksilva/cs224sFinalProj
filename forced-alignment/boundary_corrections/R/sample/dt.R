#!/path/to/R

# install.packages("rpart")
library(rpart)

# temp <- matrix(c('a','b',0.1,'b','c',0.2),ncol=3,byrow=TRUE)
train <- read.csv(file='train.csv',sep='\t',header=T)

colnames(train) <- c("Left","Right","Diff")
train_df <-  data.frame(train)
fit_dt <- rpart(Diff~Left + Right, method="anova", data = train_df) 

# temp3 <- temp2[1,1:2]
test <- read.csv(file='test.csv',sep='\t',header=T)
test_df <-  data.frame(test)

pred_diff <- predict(fit_dt, newdata= test_df)
write(prediction, "test_result.csv", sep = "\t")

# all_prediction <- data.frame(cbind(test_df, data.frame(pred_diff)))
# colnames(all_prediction) <- c("Left","Right","Predicted_Diff")
# write(all_prediction, "test_all_result.csv", sep = "\t")
