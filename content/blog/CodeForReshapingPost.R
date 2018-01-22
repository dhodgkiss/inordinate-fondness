library(tidyr)

#create the columns of the data frame
Survey <- c(1:6)
Date <- c("10/06/2017","18/06/2017","25/06/2017",
          "05/07/2017", "12/07/2017","21/07/2017")
Site <- c("CO1","CO2","CO3","OP1","OP2","OP3")
Bumblebees <- c(5,4,10,8,3,2)
Honeybees <- c(2,1,5,3,2,7)
Hoverflies <- c(3,0,1,2,5,9)
Solitary_Bees <- c(0,2,1,5,4,2)

#assemble the data frame
poldat <- data.frame(Survey, Date, Site, 
                     Bumblebees,Honeybees,Solitary_Bees)
head(poldat)
str(poldat)

#convert poldat to long format
poldat.long <- poldat %>%
  gather(FunctGroup, Count, Bumblebees:Solitary_Bees, factor_key = TRUE)
head(poldat.long)
str(poldat.long)

#convert poldat.long back to wide format
poldat.wide <- poldat.long %>%
  spread(FunctGroup, Count)
str(poldat.wide)
head(poldat.wide)

#Check if the rearranged 'poldat.wide' table is 
#equal to the original 'poldat' table
all(poldat == poldat.wide)
