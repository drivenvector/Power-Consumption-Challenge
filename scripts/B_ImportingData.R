##### Import the datasets #####
train <- read_csv('datasets/consumption_train.csv')
meta <- read_csv('datasets/meta.csv')
test <- read_csv('datasets/cold_start_test.csv')
submission_format <- read_csv('datasets/submission_format.csv')

# 1 take a look at the structure of the data
str(meta)   # 1383 obs. of  10 variables
str(train)  # 509376 obs. of  5 variables
str(test)   # 111984 obs. of  5 variables

# 2 summary of the data
summary(meta)
summary(train)
summary(test)

# 3 take a look at the top rows of the data
View(head(meta))
View(head(train))
View(head(test))


# 4 Cheking frequency in meta data
sapply(meta[-1],  table)

