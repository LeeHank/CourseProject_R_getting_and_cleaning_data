#Describing how the script works

This file is describing how the script works.
My script will use these eight files:
1. activity_labels.txt
2. features.txt
3. subject_train.txt
4. X_train.txt 
5. y_train.txt
6. subject_test.txt
7. X_test.txt
8. y_test.txt

So, I recommand that you could put these file in your working directory first,
and run the script file named "run_analysis.R".

Then, you can obtain the output data that I submitted in part1.

Here is the decription of my script:

##########
#read data
##########

train_data <-read.table("X_train.txt")
train_subject <- scan("subject_train.txt")
train_activity <- scan("y_train.txt")
test_data <-read.table("X_test.txt")
test_subject <- scan("subject_test.txt")
test_activity <- scan("y_test.txt")
activity_label <- read.table("activity_labels.txt")[,2]  #extract the activity names.
variable <- read.table("features.txt")[,2] #extract the variable names.

####################################
#step 1. merge train & test data set
####################################

#The dimenssion of the train_data is 7352*561
#The dimenssion of the test_data is 2947*561
#Because they are common in number of column,
#I use row bind command to combine these two data set

data1 <- rbind(train_data, test_data) 

########################################
#step 2. extract only mean and std measure
########################################

#I use the "grep" command to find which position of variable object
#contains the charater "mean" and "std".
#And I use  sort command to make index as ascending order.
#Finally, I extract only mean and std measure from data1 to data2 
#by using subset command.

contain_mean <- grep("mean", variable)
contain_std <- grep("std", variable)
index <- sort(c(contain_mean, contain_std))
data2 <- data1[,index]

############################
#step 3. give activity names
############################

#I first call the package "recode".
#Then use the recode command to give each activity code names.
#For example, 1 means walking, 2 means walking upstairs, and so on.

library(recode)
activity_merge <- c(train_activity, test_activity)
activity <- recode(activity_merge, "1='WALKING'; 2='WALKING_UPSTAIRS'; 3='WALKING_DOWNSTAIRS'; 4='SITTING'; 5='STANDING'; 6='LAYING'")
activity <- factor(activity, levels=activity_label)
data3 <- cbind(activity, data2)

############################
#step 4. label the data set
############################

#I use the "index" object (obtain from step 2) to extract
#column names from variable object.
#And I use column bind command to combine subject, session, and data3.
#Finally, I give each colum names.

session <- c(rep("train", length(train_subject)), rep("test", length(test_subject)))
subject <- c(train_subject, test_subject)
data4 <- cbind(subject, session, data3)
variable_name <- as.character(variable[index])
colnames(data4) <- c("subject", "session", "activity", variable_name)

###############################
#step 5. create second tidy data
###############################

#The row number of data4 is 10299, and the column number is 81.
#It represents that we have 81 measurement and 10299 subject*activity combination.
#Now, I want to create the second tidy data.
#This new data will average each measurement by one subject in one activity.
#That is, one subjet have only one average measure in one activity.
#Therefore, the row number of this data is 180 (30 subjects * 6 activities),
#and the column number of this data is still 81.
#I'll call the package "reshape2" first, and use the "melt" and "dcast" to do so.

library(reshape2)
data4_melt <- melt(data4, id=c("subject", "session", "activity"), measure.vars=variable_name)
data5 <- dcast(data4_melt, subject+activity~variable, mean)

############
#data output
############

#I write two data format for you.
#You can choose any of them you like.

write.table(data5, "tidy_data.txt")
write.csv(data5, "tidy_data.csv")

##############
#read my data
##############

data <- read.table("tidy_data.txt")
data <- read.csv("tidy_data.csv")

