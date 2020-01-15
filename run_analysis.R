library(dplyr)

# Check to see if raw data file already exists, download if not
zipped <- "raw_data_zipped.zip"

if (!file.exists(zipped)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, zipped, method="curl")
}

# Unzip data
if (!file.exists("UCI HAR Dataset")) { 
    unzip(zipped) 
}

# Create dataframes from unzipped files
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
X_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
X_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")


# Merge datasets into single dataframe
X <- rbind(X_train, X_test)
y <- rbind(y_train, y_test)
subject <- rbind(subject_train, subject_test)
merged <- cbind(X, y, subject)

# Select features containing "mean" or "std"
newfeats <- grep("\\.mean\\.|\\.std\\.", names(merged), value = TRUE)
trimmed <- merged[,c(newfeats, "code", "subject")]

# Assign names to the activity codes
trimmed$code <- activities[trimmed$code, 2]

# Rename columns
trimmed <- trimmed %>% rename(activity=code)
names(trimmed) <- gsub("-", "_", names(trimmed))
names(trimmed) <- gsub("Acc", "Accelerometer", names(trimmed))
names(trimmed) <- gsub("Gyro", "Gyroscope", names(trimmed))
names(trimmed) <- gsub("BodyBody", "Body", names(trimmed))
names(trimmed) <- gsub("Mag", "Magnitude", names(trimmed))
names(trimmed) <- gsub("^t", "Time", names(trimmed))
names(trimmed) <- gsub("^f", "Frequency", names(trimmed))
names(trimmed) <- gsub("tBody", "TimeBody", names(trimmed))
names(trimmed) <- gsub("-mean()", "Mean", names(trimmed), ignore.case = TRUE)
names(trimmed) <- gsub("-std()", "STD", names(trimmed), ignore.case = TRUE)
names(trimmed) <- gsub("-freq()", "Frequency", names(trimmed), ignore.case = TRUE)
names(trimmed) <- gsub("angle", "Angle", names(trimmed))
names(trimmed) <- gsub("gravity", "Gravity", names(trimmed))

# Tidy data set with the average of each variable for each activity and each subject
tidy <- trimmed %>% group_by(subject, activity) %>% summarize_all(mean)
write.table(tidy, "TidyData.txt", row.name=FALSE)