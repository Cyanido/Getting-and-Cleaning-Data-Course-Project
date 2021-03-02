## download the file into a new folder and unzip it
if (!file.exists("./S3")){ dir.create("./S3")}
setwd("./S3")
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, dest= "dataset.zip", methode = "curl")
### unzip the file
unzip(zipfile = "dataset.zip")
#STEP 1:Merges the training and the test sets to create one data set.
library(data.table)
##here: features(feas) for x; activity(act) for y
##here: tr for train; ts for test
##read the files, and combine them using rbind
tr_feas <- fread("UCI HAR Dataset/train/X_train.txt", header = F)
tr_act <- fread("UCI HAR Dataset/train/y_train.txt", header = F)
tr_subjects <- fread("UCI HAR Dataset/train/subject_train.txt", header = F)

ts_feas <- fread("UCI HAR Dataset/test/X_test.txt", header = F)
ts_act <- fread("UCI HAR Dataset/test/y_test.txt", header = F)
ts_subjects <- fread("UCI HAR Dataset/test/subject_test.txt", header = F)

feas <- rbind(tr_feas,ts_feas)
act <- rbind(tr_act, ts_act)
subjects <- rbind(tr_subjects,ts_subjects)

##name the variables and combine them using cbind
names(act) <- "activity"
fea_names <- fread("UCI HAR Dataset/features.txt", header = F)
names(feas) <- fea_names$V2
names(subjects) <- "subjects"
data <- cbind(subjects, act, feas )

#STEP 2:Extracts only the measurements on the mean and standard deviation for each measurement. 
##find all the names with std or mean
selects <- grepl("mean\\(\\)|std", fea_names$V2)
selects <- which(selects == T) +2
# select the data.table
data <- data[,..selects]

#STEP 3:Uses descriptive activity names to name the activities in the data set
act_names <- fread("UCI HAR Dataset/activity_labels.txt", header = F)
data$activity <- factor(data$activity, 1:6, labels=act_names$V2)

#STEP 4: Appropriately labels the data set with descriptive variable names. 
library(magrittr)
names(data) %<>%
    gsub("^f", "frequency",.)%>%
    gsub("^t", "time",.)%>%
    gsub("Acc", "Accelerometer",.)%>%
    gsub("Gyro", "Gyrometer",.)%>%
    gsub("Mag", "Magnitude", .)%>%
    gsub("BodyBody", "Body",.)
    
#STEP 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
data2 <- data[, lapply(.SD, mean), keyby= .(subjects,activity)]
write.table(data2, file ="tidyset.txt", row.names = F)

#Producing Codebook
library(knitr)
knit2html(input = "run_analysis.txt",output="Codebook.Rmd")
