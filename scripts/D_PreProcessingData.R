##### tidying meta data #####
# 1. Converting dummy variable for surface
meta %<>% 
  mutate(v = 1, sf = surface) %>% 
  spread(sf, v, fill = 0)

# 2. Renaming dummy columns from surface
meta %<>% rename(is_large = large)        # large
meta %<>% rename(is_medium = medium)      # medium
meta %<>% rename(is_Xlarge = 'x-large')   # xlarge
meta %<>% rename(is_Xsmall = 'x-small')   # x small
meta %<>% rename(is_XXlarge = 'xx-large') # xx-large
meta %<>% rename(is_XXsmall = 'xx-small') # xx-small
meta %<>% rename(is_small = small)        # small
meta %<>% rename(is_baseTemperatureHigh = base_temperature) # base Temperature

# 3. change high = 1 and low = 0 in base_temperature
meta$is_baseTemperatureHigh <- if_else(meta$is_baseTemperatureHigh == 'high', 1, 0) 

# 4. Converting False to 0 and True to 1 in days columns
meta %<>% mutate_at(vars(ends_with('_is_day_off')),
                                 funs(case_when(
                                  . =='False' ~ 0,
                                  . == 'True'~ 1)))

# 5. Converting the newly created dummy var datatype from numeric to factor 
# except the series_id column:
meta %<>% mutate_at(vars(-series_id), funs(as.factor(.)))

# Caution: will convert all the column to factor
#### meta %<>% mutate_if(is.numeric, as.factor) 


# 6. Dropping column surface
meta$surface <- NULL 


# Save an object to a file
saveRDS(meta, file = "./processed/meta.rds")
# Restore the object
openRDS(file = "./processed/meta.rds")
##############################################################


##### tidying train data #####
# Column(s) to add
# Extracting hour from timestamp and storing it as factor
train$hour <- as.factor(hour(train$timestamp))
test$hour <- as.factor(hour(test$timestamp))
View(head(test))
View(head(train))

# Imputing implicit missing values in consumption by taking median of consu in
# xsmall and xxsmall
# Check summary
summary(train$consumption)
summary(test$consumption)

# Count of values that have consumption 0:
train %>% count(consumption == 0)
test %>% count(consumption == 0)

#Converting 0 value of consumption to NA:
train %<>% mutate(consumption = na_if(consumption,0))
test %<>% mutate(consumption = na_if(consumption,0)) 

#Number of missing values before implicit conversion:
sum(is.na(train$consumption))
sum(is.na(test$consumption))

# Replacing NA with median values 
train %<>% mutate_at(vars(consumption), funs(ifelse(is.na(.),median(., na.rm = TRUE),.)))
test %<>% mutate_at(vars(consumption), funs(ifelse(is.na(.), median(., na.rm = TRUE), .)))

# Check summary
summary(train$consumption)
summary(test$consumption)


# Transformation of the consumption data. THIS STEP WAS NOT DONE
train %<>% mutate(consumption = log(consumption))

# Take a look at the transformed values of consumption
summary(train$consumption)

  
# Column(s) to drop
train$X1 <- NULL
test$X1 <- NULL

train$temperature <- NULL
test$temperature <- NULL


# Names of columns of train data
colnames(train)
colnames(test)
##############################################################

######### Save the data so far #############################
# Save an object to a file
saveRDS(train, file = "./processed/train.rds")
# Restore the object
train <- openRDS(file = "./processed/train.rds")

# Save an object to a file
saveRDS(test, file = "./processed/test.rds")
# Restore the object
test <- openRDS(file = "./processed/test.rds")

##### Joining data #####

# left join between train and meta
train_meta_lj <- left_join(x= train, y = meta, suffix = c(".x", ".m1"))
View(head(train_meta_lj))


# left join between test and meta
test_meta_lj <- left_join(x= test, y= meta, suffix = c(".y", ".m2"))
View(head(test_meta_lj))


##############################################################



########### Save the joined objects #########################
# Save an object to a file
saveRDS(train_meta_lj, file = "./processed/train_meta_lj.rds")
# Restore the object
train_meta_lj <- openRDS(file = "./processed/train_meta_lj.rds")

# Save an object to a file
saveRDS(test_meta_lj, file = "./processed/test_meta_lj.rds")
# Restore the object
test_meta_lj <- openRDS(file = "./processed/test_meta_lj.rds")
################################################################

# View sample data from the objects before writing them to file
View(head(train_meta_lj))
View(head(test_meta_lj))

# Write the objects to a file

write.csv(train_meta_lj,'./processed/consumption_train.csv')
write.csv(test_meta_lj,'./processed/cold_start_test.csv')

####################################################

# This code was not executed
##### Converting join data frames to xts object #####
train_ts <- xts(x = train_meta_lj, order.by = train_meta_lj$timestamp)
test_ts <- xts(x = test_meta_lj, order.by = test_meta_lj$timestamp)

###############################################################