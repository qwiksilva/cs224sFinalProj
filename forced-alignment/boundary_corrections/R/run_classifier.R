# #############
# ############# Generate Testing Data
# #############

# all_test_df <- data.frame()

# ### DT_diff
# test_path <- "../Python/test_DT_diff"
# test_filenames <- list.files(test_path, pattern="*.csv", full.names=FALSE)
# num_test_files <- length(test_filenames)
# test_df <- data.frame()
# for (i in 1:num_test_files){
#     # if( test_filenames[i] != "2151-A-0017.csv"){
#     temp_test_file_path <- paste(test_path, "/",test_filenames[i], sep="") 
#     if( file.info(temp_test_file_path)$size > 1){
#         train <- read.csv(file=temp_test_file_path,sep='\t',header=F)
#         colnames(train) <- c("DT_Diff")
#         cur_test_df <-  data.frame(train)
#         # print(nrow(cur_test_df))
#         test_df <-  data.frame(rbind(test_df, cur_test_df))
#     }else{
#         # print(0)
#     }
# }
# all_test_df <- test_df
# # all_test_df <- cbind(all_test_df, test_df)

# ### GBM_diff
# test_path <- "../Python/test_GBM_diff"
# test_filenames <- list.files(test_path, pattern="*.csv", full.names=FALSE)
# num_test_files <- length(test_filenames)
# test_df <- data.frame()
# for (i in 1:num_test_files){
#     temp_test_file_path <- paste(test_path, "/",test_filenames[i], sep="") 
#     if( file.info(temp_test_file_path)$size > 1){
#         train <- read.csv(file=temp_test_file_path,sep='\t',header=F)
#         colnames(train) <- c("GBM_Diff")
#         cur_test_df <-  data.frame(train)
#         # print(nrow(cur_test_df))
#         test_df <-  data.frame(rbind(test_df, cur_test_df))
#     }else{
#         # print(0)
#     }
# }
# all_test_df <- cbind(all_test_df, test_df)

# ### Mean_diff
# test_path <- "../Python/test_Mean_diff"
# test_filenames <- list.files(test_path, pattern="*.csv", full.names=FALSE)
# num_test_files <- length(test_filenames)
# test_df <- data.frame()
# for (i in 1:num_test_files){
#     temp_test_file_path <- paste(test_path, "/",test_filenames[i], sep="") 
#     if( file.info(temp_test_file_path)$size > 1){
#         train <- read.csv(file=temp_test_file_path,sep='\t',header=F)
#         colnames(train) <- c("Mean_Diff")
#         cur_test_df <-  data.frame(train)
#         # print(nrow(cur_test_df))
#         test_df <-  data.frame(rbind(test_df, cur_test_df))
#     }else{
#         # print(0)
#     }
# }
# all_test_df <- cbind(all_test_df, test_df)

# ### Median_diff
# test_path <- "../Python/test_Median_diff"
# test_filenames <- list.files(test_path, pattern="*.csv", full.names=FALSE)
# num_test_files <- length(test_filenames)
# test_df <- data.frame()
# for (i in 1:num_test_files){
#     temp_test_file_path <- paste(test_path, "/",test_filenames[i], sep="") 
#     if( file.info(temp_test_file_path)$size > 1){
#         train <- read.csv(file=temp_test_file_path,sep='\t',header=F)
#         colnames(train) <- c("Median_Diff")
#         cur_test_df <-  data.frame(train)
#         # print(nrow(cur_test_df))
#         test_df <-  data.frame(rbind(test_df, cur_test_df))
#     }else{
#         # print(0)
#     }
# }
# all_test_df <- cbind(all_test_df, test_df)

#############
############# Generate Training Data
#############

all_train_df <- data.frame()

### target
train_path <- "../Python/train_input"
train_filenames <- list.files(train_path, pattern="*.csv", full.names=FALSE)
num_train_files <- length(train_filenames)
train_df <- data.frame()
for (i in 1:num_train_files){
    temp_train_file_path <- paste(train_path, "/",train_filenames[i], sep="") 
    train <- read.csv(file=temp_train_file_path,sep='\t',header=T)
    colnames(train) <- c("","","True_Diff")
    cur_train_df <-  data.frame(train$True_Diff)
    colnames(cur_train_df) <- c("True_Diff")
    # print(nrow(cur_train_df))
    train_df <-  data.frame(rbind(train_df, cur_train_df))
}
all_train_df <- train_df

### DT_diff
train_path <- "../Python/train_DT_diff"
train_filenames <- list.files(train_path, pattern="*.csv", full.names=FALSE)
num_train_files <- length(train_filenames)
train_df <- data.frame()
for (i in 1:num_train_files){
    # if( train_filenames[i] != "2151-A-0017.csv"){
    temp_train_file_path <- paste(train_path, "/",train_filenames[i], sep="") 
    if( file.info(temp_train_file_path)$size > 1){
        train <- read.csv(file=temp_train_file_path,sep='\t',header=F)
        colnames(train) <- c("DT_Diff")
        cur_train_df <-  data.frame(train)
        # print(nrow(cur_train_df))
        train_df <-  data.frame(rbind(train_df, cur_train_df))
    }else{
        # print(0)
    }
}
all_train_df <- cbind(all_train_df, train_df)

### GBM_diff
train_path <- "../Python/train_GBM_diff"
train_filenames <- list.files(train_path, pattern="*.csv", full.names=FALSE)
num_train_files <- length(train_filenames)
train_df <- data.frame()
for (i in 1:num_train_files){
    temp_train_file_path <- paste(train_path, "/",train_filenames[i], sep="") 
    if( file.info(temp_train_file_path)$size > 1){
        train <- read.csv(file=temp_train_file_path,sep='\t',header=F)
        colnames(train) <- c("GBM_Diff")
        cur_train_df <-  data.frame(train)
        # print(nrow(cur_train_df))
        train_df <-  data.frame(rbind(train_df, cur_train_df))
    }else{
        # print(0)
    }
}
all_train_df <- cbind(all_train_df, train_df)

### Mean_diff
train_path <- "../Python/train_Mean_diff"
train_filenames <- list.files(train_path, pattern="*.csv", full.names=FALSE)
num_train_files <- length(train_filenames)
train_df <- data.frame()
for (i in 1:num_train_files){
    temp_train_file_path <- paste(train_path, "/",train_filenames[i], sep="") 
    if( file.info(temp_train_file_path)$size > 1){
        train <- read.csv(file=temp_train_file_path,sep='\t',header=F)
        colnames(train) <- c("Mean_Diff")
        cur_train_df <-  data.frame(train)
        # print(nrow(cur_train_df))
        train_df <-  data.frame(rbind(train_df, cur_train_df))
    }else{
        # print(0)
    }
}
all_train_df <- cbind(all_train_df, train_df)

### Median_diff
train_path <- "../Python/train_Median_diff"
train_filenames <- list.files(train_path, pattern="*.csv", full.names=FALSE)
num_train_files <- length(train_filenames)
train_df <- data.frame()
for (i in 1:num_train_files){
    temp_train_file_path <- paste(train_path, "/",train_filenames[i], sep="") 
    if( file.info(temp_train_file_path)$size > 1){
        train <- read.csv(file=temp_train_file_path,sep='\t',header=F)
        colnames(train) <- c("Median_Diff")
        cur_train_df <-  data.frame(train)
        # print(nrow(cur_train_df))
        train_df <-  data.frame(rbind(train_df, cur_train_df))
    }else{
        # print(0)
    }
}
all_train_df <- cbind(all_train_df, train_df)

#############
############# Run Regression Model
#############
all_train_feat <- all_train_df[,2:5]
all_train_target <- all_train_df[,1]

x<-data.matrix( all_train_feat[,])
class(x) <- "double"

y<-as.double(all_train_target)

# x_test <- data.matrix( all_test_df[,])
# class(x_test) <- "double"

########## LASSO
library(glmnet)
lasso_model.cv <- cv.glmnet(x, y, alpha=1)
# lasso_pred <- predict(lasso_model.cv, x_test)

########### SVM ALL
library("e1071")
svm_model <- svm(x, y)
# svm_pred  <- predict(svm_model, x_test)

########### SVM RBF wtih tune
# obj <- tune(svm, x, y,
#                   ranges = list(gamma = 2^(-1:1), cost = 2^(2:4)),
#                   tunecontrol = tune.control(sampling = "fix")
# )

svm_rbf_model <- svm(x, y, scale = TRUE, kernel = "radial", degree = 3, gamma = 0.5, coef0 = 0, cost = 4)
# svm_rbf_pred  <- predict(svm_rbf_model, x)

##### Random Forest
library(randomForest)
# rf_tune <- tuneRF(x, y,  mtryStart=1, ntreeTry=50)
# rf_tune <- tuneRF(x, y,  stepFactor=1.5)
rf_model <- randomForest(y ~ ., data=x, mtry=3, importance=TRUE, na.action=na.omit)
# rf_pred <- predict(rf_model, x_test)


#############
############# Out Testing Results
#############

test_path <- "../Python/test_DT_diff"
test_filenames <- list.files(test_path, pattern="*.csv", full.names=FALSE)
num_test_files <- length(test_filenames)
test_df <- data.frame()

for (i in 1:num_test_files){
    
    all_test_df <- data.frame()

    ### DT
    test_path <- "../Python/test_DT_diff"
    # if( test_filenames[i] != "2151-A-0017.csv"){
    temp_test_file_path <- paste(test_path, "/",test_filenames[i], sep="") 
    if( file.info(temp_test_file_path)$size > 1){
        test_set <- read.csv(file=temp_test_file_path,sep='\t',header=F)
        colnames(test_set) <- c("DT_Diff")
        test_df <-  data.frame(test_set)
    }
    all_test_df <- test_df

    ### GBM
    test_path <- "../Python/test_GBM_diff"
    # if( test_filenames[i] != "2151-A-0017.csv"){
    temp_test_file_path <- paste(test_path, "/",test_filenames[i], sep="") 
    if( file.info(temp_test_file_path)$size > 1){
        test_set <- read.csv(file=temp_test_file_path,sep='\t',header=F)
        colnames(test_set) <- c("GBM_Diff")
        test_df <- data.frame(test_set)
    }
    all_test_df <- cbind(all_test_df, test_df)

    ### Mean
    test_path <- "../Python/test_Mean_diff"
    # if( test_filenames[i] != "2151-A-0017.csv"){
    temp_test_file_path <- paste(test_path, "/",test_filenames[i], sep="") 
    if( file.info(temp_test_file_path)$size > 1){
        test_set <- read.csv(file=temp_test_file_path,sep='\t',header=F)
        colnames(test_set) <- c("Mean_Diff")
        test_df <- data.frame(test_set)
    }
    all_test_df <- cbind(all_test_df, test_df)

    ### Median
    test_path <- "../Python/test_Median_diff"
    # if( test_filenames[i] != "2151-A-0017.csv"){
    temp_test_file_path <- paste(test_path, "/",test_filenames[i], sep="") 
    if( file.info(temp_test_file_path)$size > 1){
        test_set <- read.csv(file=temp_test_file_path,sep='\t',header=F)
        colnames(test_set) <- c("Median_Diff")
        test_df <- data.frame(test_set)
    }
    all_test_df <- cbind(all_test_df, test_df)

    #### Format x_test
    x_test <- data.matrix( all_test_df[,])
    class(x_test) <- "double"
    
    ###Apply different models
    test_path <- "../Python/train_input"

    #### LASSO
    test_pred_path <-"../Python/test_diff_LASSO/"
    pred_diff <- data.frame()
    if(nrow(test_df)>0){
        pred_diff <- predict(lasso_model.cv, x_test)
    }
    temp_pred_file_path <- paste(test_pred_path,test_filenames[i], sep="") 
    write(pred_diff, temp_pred_file_path, sep = "\n")

    #### SVM
    test_pred_path <-"../Python/test_diff_SVM/"
    pred_diff <- data.frame()
    if(nrow(test_df)>0){
        pred_diff  <- predict(svm_model, x_test)
    }
    temp_pred_file_path <- paste(test_pred_path,test_filenames[i], sep="") 
    write(pred_diff, temp_pred_file_path, sep = "\n")

    #### SVM_RBF
    test_pred_path <-"../Python/test_diff_SVM_RBF/"
    pred_diff <- data.frame()
    if(nrow(test_df)>0){
        pred_diff  <- predict(svm_rbf_model, x_test)
    }
    temp_pred_file_path <- paste(test_pred_path,test_filenames[i], sep="") 
    write(pred_diff, temp_pred_file_path, sep = "\n")

    #### RF
    test_pred_path <-"../Python/test_diff_RF/"
    pred_diff <- data.frame()
    if(nrow(test_df)>0){
        pred_diff  <- predict(rf_model, x_test)
    }
    temp_pred_file_path <- paste(test_pred_path,test_filenames[i], sep="") 
    write(pred_diff, temp_pred_file_path, sep = "\n")
}