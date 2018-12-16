# Difference between postixit and posixct:
# https://stackoverflow.com/questions/10699511/difference-between-as-posixct-as-posixlt-and-strptime-for-converting-character-v
# https://data.library.virginia.edu/working-with-dates-and-time-in-r-using-the-lubridate-package/
datetime_test <- train[1:10, 'timestamp']
View(datetime_test)
str(datetime_test)

datetime_test_strptime <- strptime(datetime_test, format = "%Y-%m-%d %H:%M:%S")
str(datetime_test_strptime)
datetime_test_strptime <- as.POSIXct(datetime_test_strptime)

rm(datetime_test_strptime)
rm(datetime_test)


train_ts <- xts(x = train, order.by = train$timestamp)

str(meta)
cols <- c("")
# mutate_at(cols, factor)
meta %<>% mutate_if(is.numeric, as.factor)

train_for_timestamp <- read.csv('datasets/consumption_train.csv')
train_for_timestamp$timestamp <- as.POSIXct(train_for_timestamp$timestamp)
str(train_for_timestamp)
str(train)

train$timestamp <- as.POSIXct(train_for_timestamp$timestamp)

train_meta_lj <- left_join(x= train, y = meta, suffix = c(".x", ".m1"))
View(head(train_meta_lj))


train_impTemp <- train %>% na.fill(temperature, fill = na.approx())
train_impTemp <- train %>% na
  

