#####  Load libraries if they exist else install them #####
requiredPackages = c('caret', 'e1071','broom',
                     'tidyverse', 'lubridate','mice', 'magrittr',
                     'prophet', 'zoo', 'forecast', 'xts')
for(p in requiredPackages)
{
  if(!require(p,character.only = TRUE)) 
  {
    install.packages(p,dependencies=TRUE, repos='http://cran.rstudio.com/')
    print(paste(p,"installed successfully"))
    library(p,character.only = TRUE)
  }
  else{print(paste(p , "library already installed"))}
}
print("List of the attached packages in your session: " )
search()



##### Set seed for reproducibility purpose #####
# set.seed(128)




### Set options if needed ###
options(scipen = 999)

rm(p)
rm(requiredPackages)
