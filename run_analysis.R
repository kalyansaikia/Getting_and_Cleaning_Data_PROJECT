# Download the dataFile from Internet

getwd()
fileurl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl, destfile = "./dataset.zip")

#Unzipping the data files 

unzip(zipfile = "dataset.zip", exdir = "./data")

# Creating a list of files

allfiles<-list.files("./data/UCI HAR DATASET", recursive = TRUE)
allfiles #viewing list of all fiels

# For the purpose current we will be only using only 6 files
# test/subject_test.txt -- Subject file
# test/X_test.txt --------- Data File
# test/y_test.txt ---------Activity
# train/subject_train.txt -- -- Subject file
# train/X_train.txt ---------Data File
# train/y_train.txt ---------Activity

# Read Activity Files

ActivityTest  <- read.table(file.path("./data/UCI HAR DATASET/test","Y_test.txt") ,header = FALSE)
ActivityTrain <- read.table(file.path("./data/UCI HAR DATASET/train", "Y_train.txt"),header = FALSE)

# Read Subject Files

SubjectTrain <- read.table(file.path("./data/UCI HAR DATASET/train", "subject_train.txt"),header = FALSE)
SubjectTest  <- read.table(file.path("./data/UCI HAR DATASET/test", "subject_test.txt"),header = FALSE)

# Read Features Files

FeaturesTest  <- read.table(file.path("./data/UCI HAR DATASET/test", "X_test.txt" ),header = FALSE)
FeaturesTrain <- read.table(file.path("./data/UCI HAR DATASET/train", "X_train.txt"),header = FALSE)

# Checking the STRUCTURE of the data set created in above step

str(ActivityTest)
str(ActivityTrain)
str(SubjectTest)
str(SubjectTrain)
str(FeaturesTest)
str(FeaturesTrain)

# Merging training and test data set using rbind
activitydata<-rbind(ActivityTrain, ActivityTest)
subjectdata<- rbind(SubjectTest, SubjectTrain)
featuresdata<- rbind(FeaturesTest, FeaturesTrain)

# Setting Names to Variables of Each combined data frame

names(activitydata)<- c("activity")
names(subjectdata)<- c("subject")
names(featuresdata)<-c(read.table(file.path("./data/UCI HAR DATASET","features.txt"), head=FALSE))$V2

# Combining All three Data Frames into a single one

datacomb<- cbind(activitydata, subjectdata, featuresdata)

# Subsetting the Combined dataset with selection of mean and Standard Deviation

namedatafeature<-read.table(file.path("./data/UCI HAR DATASET","features.txt"), head=FALSE)
selecnamedfeature<-namedatafeature$V2[grep("mean\\(\\)|std\\(\\)",namedatafeature$V2)]
selectednames<-c(as.character(selecnamedfeature),"subject","activity")
datasub<- subset(datacomb, select = selectednames)

# Check Structure of datasub
str(datasub)
View(datasub)

# Converting numeric value of actvity to activity levels

activityLabels <- read.table(file.path("./data/UCI HAR DATASET", "activity_labels.txt"),header = FALSE)
activityLabels
datasub$activity <- factor(datasub$activity, levels = activityLabels[,1], labels = activityLabels[,2])
head(datasub$activity, 20)

#Cleaning up the Variable names

names(datasub)<-gsub("\\()","", names(datasub))
names(datasub)<-gsub("-std$","StdDev", names(datasub))
names(datasub)<-gsub("-mean$","Mean", names(datasub))
names(datasub)<-gsub("^t", "time", names(datasub))
names(datasub)<-gsub("^f", "frequency", names(datasub))
names(datasub)<-gsub("Acc", "Accelerometer", names(datasub))
names(datasub)<-gsub("Gyro", "Gyroscope", names(datasub))
names(datasub)<-gsub("Mag", "Magnitude", names(datasub))
names(datasub)<-gsub("BodyBody", "Body", names(datasub))

# Check cleaned variable names
names(datasub)

# Using above dataset, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(plyr)
aggreData<-aggregate(. ~subject + activity, datasub, mean)
sortaggredata<-aggreData[order(aggreData$subject,aggreData$activity),]

# Creating a file named 'tinydata'
write.table(sortaggredata, file = "tinydata.txt",row.names=FALSE)


