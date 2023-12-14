# ARDC Summer school - introduction to data wrangling in R #

##############################
# Base R
##############################

##############################
## Clean environment ##
rm(list=ls())

## vector ##
### Create a numeric vector and save it as "mv1"
mv1 <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20)

### Print an object
print(mv1)
### In most cases, it is enough to type just the name of the object 
mv1

### other ways to create vectors

mv2 <- c(1:20)
mv3 <- mv2/10
mv4 <- c(1:4, 20:24, 1:11)
mv5 <- rep(1:4,5)

### check the data type
typeof(mv1)
typeof(mv2)
typeof(mv3)
# only mv2 is integer

## Other data types
### logical
mv6 <- mv4 == mv5 # Are corresponding values in mv4 and mv5 equal?
mv6

### character
mv7 <- rep(c("a","b","c","d","e"),4)
mv7 

### Coercion 
mv8 <- c(1,3,4,"a")
mv8 # Note that all numbers are stored as characters
as.numeric(mv8) # Converting the vector to numeric will replace non-numbers to NA (missing)
as.character(mv1) # Converting to character

### adding NA to a vector
mv9 <- c(1,3,4,NA) 
mv9

##############################
## matrix ##
matrix(c("a","b","c","d"), 2)

##############################
## list ##
list("a", c(1:3), mv1)

##############################
## create a data.frame
mdf <- data.frame(mv2, mv4, mv7, y = c(25:44)) # Note that all vectors must be of equal length.
mdf

##############################
# Inspecting data objects
##############################
view(mdf)

# Structure of an object
str(mdf)

# Frequency table for a vector (not part of a data frame)
table(mv5)

# A frequency table for a column of a data.frame. $ is used to access a specific column of a data.frame.
table(mdf$mv4)


mean(mv1)
mean(mv9) # If there are missing values mean() returns NA
mean(mv9, na.rm = T) # We need to tell the function to omit NAs

# Print summary statistics for a vector or all columns in a data.frame
summary(mv1)
summary(mdf)

##############################
# Subsetting in base R
##############################

# Extracting vector elements
mv1
## Using position
mv1[5] # Return the fifth element
mv1[5:10] # Return elements from 5 to 10
mv1[c(7:10,1,4)] # Return elements from 7 to 10, first, and forth - this will change the order 

## Using a condition
mv1[mv1 < 10] # Return the elements of vector mv1 which are smaller than 10. The condition in [] produces a logical vector which is used to extract elements.

mv1[c(TRUE, FALSE)] # Any logical vector can be used for filtering
mv1[mv6]
mv1[rep(mv6,10)] 

# Pass a subset of values to another function
mean(mv1[mv1 < 10]) # Calculate mean of values of vector mv1 that are smaller than 10

# Extract data.frame elements
## Using positions - df[rows indices, column indices]
mdf[4:5,2:3] # Select rows 4 and 5 and columns 2 and 3. 
## Using conditions 
mdf[mv2 < 3, 2:3] # Select rows for which mv3 is smaller than 3 and columns 2 and 3. 

##############################
# Installing and loading packages
##############################

# install.packages("tidyverse") # Required only once
library(tidyverse) # Required for every new R session

##############################
# Loading data files
##############################
setwd("~/HASS_Summer_School/managing_data")

# Load higher education data
edu <- read_csv("data/ARDC_SS_2023_higher_education.csv")

# Inspect the data
str(edu) # the structure
head(edu) # first rows
print(edu, n = 16, width = Inf) # print more rows and all columns
view(edu) # all elements in an excel-like view
names(edu) # return list of column names (it is a character vector)

##############################
# Subsetting/filtering rows
##############################

# Select individuals who graduated in 2011
table(edu$hied_2011_completion_flag)

filter(edu, hied_2011_completion_flag == 1)
filter(edu, hied_2011_completion_flag == "1")

# Select individuals who graduated from a BA course in 2011 and save the new data.frame as edu2
edu2 <- filter(edu, hied_2011_completion_flag == "1" & hied_2011_level %in% c(9,10))

nrow(edu) # check the number of rows
nrow(edu2)
rm(edu2) # Remove the file

##############################
# Subsetting/selecting variables
##############################

# Dplyr selection by index
select(edu, 7:12)
select(edu, 7,1,3)
select(edu, 7,1:3)

# Select by names
select(edu, MADIP_ID_04, hied_2011_completion_flag, hied_2011_completion_field) # We can change the order

select(edu, MADIP_ID_04:hied_2011_completion_flag)

select(edu, MADIP_ID_04, hied_2011_completion_field:hied_2011_completion_flag)


# Dropping variables
select(edu, -1:-6)
select(edu, -1:-6,-hied_2011_field:-hied_yr_arrival)

select(edu, starts_with("hied_2011_"))


# other useful select commands
select(edu, ends_with("field"))
select(edu, contains("2011")) #- add matches option to use regular expressions 
select(edu, c(ends_with("field"),contains("2011")))
select(edu, ends_with("field") | contains("2011"))
select(edu, ends_with("field") & contains("2011"))
select(edu,where(is.numeric))

# HE data - keep relevant variables only
select(edu, MADIP_ID_04, gender, hied_cob_2dig, hied_disability_ind, hied_indigenous_ind, hied_language_ind, hied_yr_arrival, starts_with("hied_2011_"))

##############################
# Chaining - Pipe
##############################

edu <- edu %>%
  filter(hied_2011_completion_flag == "1" & hied_2011_level %in% c(9,10)) %>%
  select(MADIP_ID_04, gender, hied_cob_2dig, hied_disability_ind, hied_indigenous_ind, hied_language_ind, hied_yr_arrival, starts_with("hied_2011_"))

head(edu)

##############################
# Creating/modifying a variable
##############################

# create a broad field of study variable
typeof(edu$hied_2011_completion_field)
head(edu$hied_2011_completion_field)

## coerce the existing variable to numeric 
edu <- edu %>%
  mutate(hied_2011_completion_field = as.numeric(hied_2011_completion_field))
head(edu$hied_2011_completion_field)
typeof(edu$hied_2011_completion_field)

## create a new variable with a 2-digit broad field code
edu <- edu %>%
  mutate(broad_FoS = floor(hied_2011_completion_field/10000))

## check the results
table(edu$hied_2011_completion_field, edu$broad_FoS)

## Keep well-defined fields only
edu <- edu %>%
  filter(broad_FoS > 0 & broad_FoS < 12)

# recode the disability variable
table(edu$hied_disability_ind, exclude = NULL)

edu <- edu %>%
  mutate(hied_disability_ind_rec = replace(hied_disability_ind, hied_disability_ind == 3, 2))

table(edu$hied_disability_ind, edu$hied_disability_ind_rec, exclude = NULL)

# modifying multiple variables - across()
edu %>%
  mutate(across(c(hied_disability_ind, hied_indigenous_ind, hied_language_ind), ~replace(.,. == 3, 2))) %>%
  select(hied_disability_ind, hied_indigenous_ind, hied_language_ind) %>%
  head()

# creating multiple new variables
edu <- edu %>%
  mutate(across(c(hied_disability_ind, hied_indigenous_ind, hied_language_ind), list(rec = ~replace(.,. == 3, 2))))

edu %>%
  select(contains(c("dis", "lang", "indi"))) %>%
  head()

############## ############## ############## ############## 
############## ############## ############## ############## 
############## add income data 
############## ############## ############## ############## 
############## ############## ############## ############## 

##############################
# Prepare income data
##############################

# read data
inc <- read_csv("data/ARDC_SS_2023_income.csv")
head(inc)

# extract columns
inc <- inc %>%
  select(MADIP_ID_04, contains(c("salary_wages")))

head(inc)

# change format to long
inc_long <- inc %>%
  pivot_longer(cols = -MADIP_ID_04, 
               names_to = c("fin_year"), 
               names_pattern = "pit_(.*)_salary_wages",
               values_to = "salary_wages") 

head(inc_long)

##############################
# Join data
##############################

edu_inc <- left_join(edu, inc_long)

##############################
# Collapse/ summarise data
##############################

names(edu_inc)

# calculate average income and the number of observations for female and male graduates of each field in each year
agg_data <- edu_inc %>%
  group_by(broad_FoS, fin_year, gender) %>%
  summarise(av_inc = mean(salary_wages, na.rm = T),
            count = n())

print(agg_data)

# change format to wide
agg_data <- agg_data %>%
  pivot_wider(id_cols = c("broad_FoS", "fin_year"), names_from = gender, values_from = c("av_inc", "count")) 

agg_data

# calculate the feminisation rate and gender pay gap
agg_data <- agg_data %>%
  mutate(total = count_F+count_M,
         fem_rate = count_F/total,
         gpg = (av_inc_M - av_inc_F)/av_inc_M)

agg_data

# plot the results

agg_data %>%
  filter(fin_year %in% c("1011","1516")) %>%
  ggplot(aes(x = av_inc_M, y = gpg, colour = factor(broad_FoS), size = total)) +
  geom_point() +
  facet_wrap(~factor(fin_year), ncol = 2L) +
  theme_minimal() +
  scale_y_continuous(labels = scales::percent_format(accuracy=1), limits = c(0,0.35), expand = c(0,0)) +
  ylab("Gender pay gap") +
  xlab("Average income among men") +
  guides(colour = guide_legend(ncol = 2)) +
  scale_size_continuous(name="N observations") +
  scale_colour_discrete(name="Field of study") +
  theme(
    axis.line = element_line(colour = "grey"),
    legend.position="bottom",
    legend.key.width = unit(1,"cm"),
    panel.spacing = unit(1.5, "lines"),
    legend.box = "horizontal",
    legend.direction = "vertical"
  ) 

