## We will look at the data and perform 'tidyfication'


# 1 take a look at the structure of the data
str(meta)   # 1383 obs. of  10 variables
str(train)  # 509376 obs. of  5 variables
str(test)   # 111984 obs. of  5 variables


# 2 tidying meta data
# Converting dummy variable for surface
# meta_data_spread <- meta %>%  spread(key = surface, value = surface)
# View(meta_data_spread)
View(head(meta))
meta<- meta %>% 
  mutate(v = 1, sf = surface) %>% 
  spread(sf, v, fill = 0)
meta$surface <- NULL  # Removing the surface variable
meta %<>% mutate_if(is.numeric, as.factor)

# 3 Renaming dummy columns from surface
meta <- meta %>% rename(is_large = large)        # large
meta <- meta %>% rename(is_medium = medium)      # medium
meta <- meta %>% rename(is_Xlarge = 'x-large')   # xlarge
meta <- meta %>% rename(is_Xsmall = 'x-small')   # x small
meta <- meta %>% rename(is_XXlarge = 'xx-large') # xx-large
meta <- meta %>% rename(is_XXsmall = 'xx-small') # xx-small
meta <- meta %>% rename(is_small = small)        # small
meta <- meta %>% rename(is_baseTemperatureHigh = base_temperature) # base Temperature
View(meta)

# 4 change high = 1 and low = 0 in base_temperature
table(meta$base_temperature)
meta$is_baseTemperatureHigh <- if_else(meta$is_baseTemperatureHigh == 'high', 1, 0) 
table(meta$is_baseTemperatureHigh)

# 
# # 5 Converting NAs to 0 and their own value to 1
# meta$is_large   <- if_else(is.na(meta$is_large), 0, 1)
# meta$is_medium  <- if_else(is.na(meta$is_medium), 0, 1)
# meta$is_Xlarge  <- if_else(is.na(meta$is_Xlarge), 0, 1)
# meta$is_Xsmall  <- if_else(is.na(meta$is_Xsmall), 0, 1)
# meta$is_XXsmall <- if_else(is.na(meta$is_XXsmall), 0, 1)
# meta$is_small   <- if_else(is.na(meta$is_small), 0, 1)
# meta$is_XXlarge <- if_else(is.na(meta$is_XXlarge), 0, 1)
View(head(meta, 10))


# 6 Converting False to 0 and True to 1 in days columns
meta$monday_is_day_off    <- if_else(meta$monday_is_day_off=="False", 0, 1)
meta$tuesday_is_day_off   <- if_else(meta$tuesday_is_day_off=="False", 0, 1)
meta$wednesday_is_day_off <- if_else(meta$wednesday_is_day_off=="False", 0, 1)
meta$thursday_is_day_off  <- if_else(meta$thursday_is_day_off =="False", 0, 1)
meta$friday_is_day_off    <- if_else(meta$friday_is_day_off=="False", 0, 1)
meta$saturday_is_day_off  <- if_else(meta$saturday_is_day_off=="False", 0, 1)
meta$sunday_is_day_off    <- if_else(meta$sunday_is_day_off=="False", 0, 1)
View(head(meta, 10))


# 7 Looking at data tidified till now
sapply(meta[-1],  table)
summary(meta)
str(meta)
sapply(meta, typeof)

# 8 Convert the numeric datatype of meta data to factorial except series_id
metaseries <- meta$series_id  # store the seriesid in this variable
meta <- meta %>% select(-series_id) %>% mutate_if(is.numeric, as.factor)
str(meta)
meta <- cbind(meta, metaseries)
meta <- meta %>% rename(series_id = 'metaseries')
View(meta)
colnames(meta)


# 9 Data cleaning in train and test sets
train$X <- NULL
test$X <- NULL

# meta data has been processed till this point. Lets save it so it saves time in future
# Save an object to a file
saveRDS(meta, file = "./processed/meta.rds")
# Restore the object
openRDS(file = "./processed/meta.rds")

# This code need not be executed
# Converting datatype of timestamp from character factor to POSIXit using strptime
train$timestamp <- strptime(train$timestamp, format = "%Y-%m-%d %H:%M:%S")
str(train)
test$timestamp <- strptime(test$timestamp, format = "%Y-%m-%d %H:%M:%S")
str(test)

# splitting timestamp into date and in time and extracting the hour part from time

#train data
train$date <- as.Date(train$timestamp)
train$timestamp <- as.POSIXct(train$timestamp)
train$time <- format(as.POSIXct(train$timestamp) ,format = "%H:%M:%S") 
train$hour <- hour(hms(as.character(train$time))) 
str(train)

#test data
test$date <- as.Date(test$timestamp)
test$timestamp <- as.POSIXct(test$timestamp)
test$time <- format(as.POSIXct(test$timestamp) ,format = "%H:%M:%S")  
test$hour <- hour(hms(as.character(test$time))) 
str(test)

# dropping time column

train$time <- NULL
test$time <- NULL

View(head(train))


# train and test data has been processed till this point. Lets save it so it saves time in future
# Save an object to a file

saveRDS(train, file = "./processed/train.rds")
# Restore the object
openRDS(file = "./processed/train.rds")

saveRDS(test, file = "./processed/test.rds")
# Restore the object
openRDS(file = "./processed/test.rds")


# 12 Checking differnce between series_id that are present in meta but not in train or test
metaButNotTrain <- as.vector(setdiff(meta$series_id, train$series_id))     
#setdiff(train$series_id, meta_data_spread$series_id)     
metaButNotTrain  # 625 values
metaButNotTest <- as.vector(setdiff(meta$series_id, test$series_id))
#setdiff(test$series_id, meta_data_spread$series_id)
metaButNotTest   # 758 values


# 10 left join between train and meta
train_meta_lj <- left_join(x= train, y = meta, suffix = c(".x", ".m1"))
View(head(train_meta_lj))


# 11 left join between test and meta
test_meta_lj <- left_join(x= test, y= meta, suffix = c(".y", ".m2"))
View(head(test_meta_lj))




# 12 looking at data so far
View(head(train_meta_lj))
View(head(test_meta_lj))


# 13 Looking at range of temperature and consumption, eliminating NA/ Inf
range(train_meta_lj$temperature, finite = 1)
min(train_meta_lj$temperature, na.rm = TRUE)
max(train_meta_lj$temperature, na.rm = TRUE)

range(train_meta_lj$consumption, finite = 1)
min(train_meta_lj$consumption, na.rm = TRUE)
max(train_meta_lj$consumption, na.rm = TRUE)


# calculating % of missing data columnwise
sort(colMeans(is.na(train_meta_lj)*100), decreasing = TRUE)  # 45% missing values of temperature
sort(colMeans(is.na(test_meta_lj)*100), decreasing = TRUE)   # 40% missing values of temperature


# Converting join data frames to xts object
train_ts <- xts(x = train_meta_lj, order.by = train_meta_lj$timestamp)
test_ts <- xts(x = test_meta_lj, order.by = test_meta_lj$timestamp)



# the code below is not executed yet and probably not needed


#  Adding source dataset column
train_meta_lj$dataset <- "train"
test_meta_lj$dataset <- "test"


# 16 Viewing number of missing values in temperature, grouping on series_id
train_missing_data <- train_meta_lj %>%
  filter(is.na(temperature))  %>%
  group_by(series_id) %>% 
  count(temperature)
View(train_missing_data)

# 17 What min, mean, max temperature for a series id
train_summary_temp_by_sid <- train_meta_lj %>% 
  group_by(series_id) %>% 
  summarise(
    numberForRecs = n(),
    numberOfNAs = sum(is.na(temperature)),
    meanTemp = mean(temperature, na.rm = TRUE),
    minTemp = min(temperature, na.rm = TRUE),
    maxTemp = max(temperature, na.rm = TRUE)
  )
View(train_summary_temp_by_sid)

train_meta_lj %>%  filter(is.numeric(unique(temperature))) %>% select(temperature)
which(is.na(train_meta_lj$temperature))









