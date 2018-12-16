# 1. How is the power consumption per hour?
# 2. How is the power consumption over days?
# 3. How do temperature and consumption vary?
  
train_nonNa <- train_meta_lj %>% na.omit()
head(train_nonNa$consumption)

ggplot(train_nonNa) +
  facet_grid(consumption ~ factor(hour)) 


getwd()
