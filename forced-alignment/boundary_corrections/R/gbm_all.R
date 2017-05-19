### RUN DT
# install.packages("rpart")
# install.packages("randomForest")
# install.packages("gbm")

library(rpart)
library(randomForest)
library(gbm)

#####

# #####
# train_filenames <- list.files("./train", pattern="*.csv", full.names=FALSE)
# # train_filenames <- list.files("./train", pattern="*.csv", full.names=TRUE)

# train_df <- data.frame()
# num_train_files <- length(train_filenames)
# for (i in 1:num_train_files){
# 	temp_train_file_path <- paste("./train/",train_filenames[i], sep="") 
# 	train <- read.csv(file=temp_train_file_path,sep='\t',header=T)
# 	colnames(train) <- c("Left","Right","Diff")
# 	cur_train_df <-  data.frame(train)
# 	train_df <-  data.frame(rbind(train_df, cur_train_df))
# }

# fit_dt <- gbm(Diff~Left + Right, data = train_df, n.trees=1000,  interaction.depth=2) 

# ######
# test_filenames <- list.files("./test", pattern="*.csv", full.names=FALSE)
# # test_filenames <- list.files("./test", pattern="*.csv", full.names=TRUE)
# num_test_files <- length(test_filenames)
# for (i in 1:num_test_files){	
# 	temp_test_file_path <- paste("./test/",test_filenames[i], sep="") 
# 	test <- read.csv(file=temp_test_file_path,sep='\t',header=T)
# 	test_df <-  data.frame(test)

# 	# pred_diff <- predict(fit_dt, newdata= test_df)
# 	pred_diff <- predict.gbm(fit_dt, test_df, type="response", n.trees=1000)
# 	# temp_pred_file_path <- paste("./pred/pred_",test_filenames[i], sep="") 
# 	temp_pred_file_path <- paste("./GBM_test_diff/",test_filenames[i], sep="") 
# 	write(pred_diff, temp_pred_file_path, sep = "\n")
# } 


#####
train_path <- "../Python/train_input"
train_filenames <- list.files(train_path, pattern="*.csv", full.names=FALSE)

train_df <- data.frame()
num_train_files <- length(train_filenames)
for (i in 1:num_train_files){
	temp_train_file_path <- paste(train_path, "/",train_filenames[i], sep="") 
	train <- read.csv(file=temp_train_file_path,sep='\t',header=T)
	colnames(train) <- c("Left","Right","Diff")
	cur_train_df <-  data.frame(train)
	train_df <-  data.frame(rbind(train_df, cur_train_df))
}

### get mean
# agg_mean <-aggregate(train_df$Diff, by=list(train_df$Left, train_df$Right), FUN=mean)
# agg_median <- aggregate(train_df$Diff, by=list(train_df$Left, train_df$Right), FUN=median)

fit_dt <- gbm(Diff~Left + Right, data = train_df, n.trees=1000,  interaction.depth=2) 

######
test_path <- "../Python/train_input"
test_pred_path <-"../Python/train_GBM_diff/"

test_filenames <- list.files(test_path, pattern="*.csv", full.names=FALSE)
num_test_files <- length(test_filenames)
for (i in 1:num_test_files){	
	temp_test_file_path <- paste(test_path, "/", test_filenames[i], sep="") 
	test <- read.csv(file=temp_test_file_path,sep='\t',header=T)
	test_df <-  data.frame(test)

	pred_diff <- data.frame()
	if(nrow(test_df)>0){
		pred_diff <- predict.gbm(fit_dt, test_df, type="response", n.trees=1000)
	}
	
	temp_pred_file_path <- paste(test_pred_path,test_filenames[i], sep="") 
	write(pred_diff, temp_pred_file_path, sep = "\n")
} 

######
test_path <- "../Python/test_input"
test_pred_path <-"../Python/test_GBM_diff/"

test_filenames <- list.files(test_path, pattern="*.csv", full.names=FALSE)
num_test_files <- length(test_filenames)
for (i in 1:num_test_files){	
	temp_test_file_path <- paste(test_path, "/", test_filenames[i], sep="") 
	test <- read.csv(file=temp_test_file_path,sep='\t',header=T)
	test_df <-  data.frame(test)

	pred_diff <- predict.gbm(fit_dt, test_df, type="response", n.trees=1000)
	
	temp_pred_file_path <- paste(test_pred_path,test_filenames[i], sep="") 
	write(pred_diff, temp_pred_file_path, sep = "\n")
} 