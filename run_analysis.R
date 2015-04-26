##########
#read data
##########

train_data <-read.table("X_train.txt")
train_subject <- scan("subject_train.txt")
train_activity <- scan("y_train.txt")
test_data <-read.table("X_test.txt")
test_subject <- scan("subject_test.txt")
test_activity <- scan("y_test.txt")
activity_label <- read.table("activity_labels.txt")[,2]
variable <- read.table("features.txt")[,2]

####################################
#step 1. merge train & test data set
####################################

data1 <- rbind(train_data, test_data)

########################################
#step 2. extract only mean and std measure
########################################
contain_mean <- grep("mean", variable)
contain_std <- grep("std", variable)
index <- sort(c(contain_mean, contain_std))
data2 <- data1[,index]


############################
#step 3. give activity names
############################

library(recode)
activity_merge <- c(train_activity, test_activity)
activity <- recode(activity_merge, "1='WALKING'; 2='WALKING_UPSTAIRS'; 3='WALKING_DOWNSTAIRS'; 4='SITTING'; 5='STANDING'; 6='LAYING'")
activity <- factor(activity, levels=activity_label)
data3 <- cbind(activity, data2)

############################
#step 4. label the data set
############################

session <- c(rep("train", length(train_subject)), rep("test", length(test_subject)))
subject <- c(train_subject, test_subject)
data4 <- cbind(subject, session, data3)
variable_name <- as.character(variable[index])
colnames(data4) <- c("subject", "session", "activity", variable_name)

###############################
#step 5. create second tidy data
###############################

library(reshape2)
data4_melt <- melt(data4, id=c("subject", "session", "activity"), measure.vars=variable_name)
data5 <- dcast(data4_melt, subject+activity~variable, mean)

############
#data output
############

write.table(data5, "tidy_data.txt")
write.csv(data5, "tidy_data.csv")

##############
#read my data
##############

data <- read.table("tidy_data.txt")
data <- read.csv("tidy_data.csv")
