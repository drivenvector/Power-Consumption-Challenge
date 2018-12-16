# Power consumption till the last date of the training data
# time_series <- ts(data_vector, start = 2004, frequency = 4)
# ts.plot(eu_stocks, col = 1:4, xlab = "Year", ylab = "Index Value", main = "Major European Stock Indices, 1991-1998")

table(meta$is_baseTemperatureHigh)
# high  low 
# 35 1348


sapply(meta[-1], table)

# Checking differnce between series_id that are present in meta but not in train or test
metaButNotTrain_sid <- as.vector(setdiff(meta$series_id, train$series_id))     
length(metaButNotTrain_sid)  # 625 values

metaButNotTest_sid <- as.vector(setdiff(meta$series_id, test$series_id))
length(metaButNotTest_sid)   # 758 values


# Missing value 
sort(colMeans(is.na(train)*100), decreasing = TRUE)  # 45% missing values of temperature
sort(colMeans(is.na(test)*100), decreasing = TRUE)   # 40% missing values of temperature


# Looking at range of temperature and consumption in train data, eliminating NA/ Inf
range(train$temperature,  finite = 1)
min(train$temperature, na.rm = TRUE)
max(train$temperature, na.rm = TRUE)

range(train$consumption, finite = 1)
min(train$consumption, na.rm = TRUE)
max(train$consumption, na.rm = TRUE)


train_trial_xts <- xts(x = train, order.by = train$timestamp, frequency = 24)
head(train_trial_xts)



ggplot(train_trial_xts, aes(x =timestamp, y = consumption)) +
  geom_line()
