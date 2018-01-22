---
title: Reshaping data frames between long and wide formats
author: the Anxious Analyst
date: '2018-01-01'
slug: 2018-01-01_reshaping_data_frames
categories:
  - R
tags:
  - reshape
  - wide/long formats
description: ''
featured: ''
featuredalt: ''
featuredpath: ''
linktitle: ''
type: 'post'
---

## Introduction

When preparing data frames for input into analyses, a common first step is to restructure the layout of the data so that you have all the necessary variables as columns and all the relevant values for each observation in rows. However, recorded data is often in a format that suits data collection, but which is unsuitable for data analysis. At times like these, rearranging the data, or 'reshaping' the data frame, is a necessary prerequisite for carrying out the analyses. This article will give a brief overview of how to reshape data frames using the `gather()` and `spread()` functions from the 'tidyr' package.

## Converting tables from wide to long format

Tables are said to be in wide format when some columns are not variables. Put another way, if you have multiple columns with values of a response variable, then your data is in wide format. An example from my research in ecology is counts of pollinators belonging to different functional groups (groups of pollinators that behave similarly when visiting flowers for pollen and nectar). A table of pollinator counts in wide format might look something like this:

[//]: # (This is a comment: For some reason this table doesn't show up properly when I add vertical lines at the end of it.)

|Survey|Date       |Site  | Bumblebees | Honeybees | Hoverflies  
|:----:|:---------:|:----:|:----------:|:---------:|:----------:
|1     |10/06/2017 |CO1   |5           |2          |3           
|2     |18/06/2017 |CO2   |4           |1          |0           
|3     |25/06/2017 |CO3   |10          |5          |1           
|4     |05/07/2017 |OP1   |8           |3          |2           
|5     |12/07/2017 |OP2   |3           |2          |5           
|6     |21/07/2017 |OP3   |2           |7          |9           

However, if you wanted to create a stacked bar chart with the relative proportions of each pollinator group across the six sites, then you would need to have this data in long format to simplify the next steps of the code for creating the bar chart. This is where the `gather()` function comes in.

### Syntax

Here is the generic syntax for the `gather()` function:

```r
reformatted_data <- input_data %>%
  gather(KeyColumnName, ValueColumnName, CurrentColumnsWithValues, factor_key = TRUE)
```
In the code above, `KeyColumnName` is the name that you want to give to the new column that will store the keys, which are the current column names that you want to collapse into a single column. `ValueColumnName` is the name of the column that will store the value associated with the each key. `CurrentColumnsWithValues` tells R which columns to extract the values from in order to reassign them to the new single column of values. Lastly, setting `factor_key` to `TRUE` means that the new key column will be stored as a factor rather than a character vector.

Thus, to rearrange data from the pollinator counts example into long format, you can use the following code and save it as a new data frame called 'poldat.long':
```r
poldat.long <- poldat %>%
  gather(FunctGroup, Count, Bumblebees:Hoverflies, factor_key = TRUE)
```
When displayed as a table, the result of this call looks like this:

|Survey|Date       |Site  |FunctGroup   | Count |
|:----:|:---------:|:----:|:-----------:|:-----:|
|1     |10/06/2017 |CO1   |Bumblebees   |5      |      
|2     |18/06/2017 |CO2   |Bumblebees   |4      |     
|3     |25/06/2017 |CO3   |Bumblebees   |10     |   
|4     |05/07/2017 |OP1   |Bumblebees   |8      |    
|5     |12/07/2017 |OP2   |Bumblebees   |3      |      
|6     |21/07/2017 |OP3   |Bumblebees   |2      |      
|1     |10/06/2017 |CO1   |Honeybees    |2      | 
|2     |18/06/2017 |CO2   |Honeybees    |1      |        
|3     |25/06/2017 |CO3   |Honeybees    |5      |  
|4     |05/07/2017 |OP1   |Honeybees    |3      |        
|5     |12/07/2017 |OP2   |Honeybees    |2      |    
|6     |21/07/2017 |OP3   |Honeybees    |7      |
|1     |10/06/2017 |CO1   |Hoverflies   |3      |     
|2     |18/06/2017 |CO2   |Hoverflies   |0      |   
|3     |25/06/2017 |CO3   |Hoverflies   |10     |    
|4     |05/07/2017 |OP1   |Hoverflies   |2      |     
|5     |12/07/2017 |OP2   |Hoverflies   |5      |        
|6     |21/07/2017 |OP3   |Hoverflies   |9      |    

Now pollinator counts are grouped into a single column that can serve as a response variable in univariate analyses, with the FunctGroup variable as a fixed effect, for example. Notice that all other columns are automatically repeated as necessary, so there are now three copies of survey, date and site values for each of the six original observations.

## Converting tables from long to wide format

If instead the data you have is in long format and you need it in wide format, then the function to use is `tidyr::spread()`. 

### Syntax

The arguments of for `spread()` are similar to those for `gather()`, only you no longer need to enter columns with the values to collapse because this time, there is only a single value column that you are separating into multiple columns:
```r
reformatted_data <- input_data %>%
  spread(KeyColumnName, ValueColumnName, fill = 0, convert = TRUE, drop = FALSE, sep = ".")
```
In the code above, I've added three optional arguments (`fill`, `convert`, `drop` and `sep`). `fill` and `drop` apply to situations where you do not have all combinations of factor levels for each observation. So in our pollinator count example, if some sites did not have data for all three pollinator groups, then setting `fill = 0` would mean that missing factor levels would be filled in with a count of `0`. Setting `drop = TRUE`, on the other hand, would omit these missing factor-observation combinations altogether. The default setting for `drop` is `drop = FALSE`, so in most circumstances it's unnecessary to include it. 

`convert` defaults to `FALSE`; however, it can be useful to set it to `TRUE` as it will then convert the type of the new columns to an integer, in this case, rather than having them as type number or character (for strings), which happens by default. Lastly, setting `sep = "."` means that the new column names will take the form of KeyName.KeyValue. Hence, in our pollinator count example, the new columns would be named FunctGroup.Bumblebees, FunctGroup.Honeybees and FunctGroup.Hoverflies. The default setting is `sep = NULL`, which means the names of the new columns are simply the key values themselves (Bumblebees, Honeybees and Hoverflies), which is often appropriate. Therefore, in this case, rearranging the 'poldat.long' to wide format could be done using the following code:
```r
poldat.wide <- poldat.long %>%
  spread(FunctGroup, Count)
```  
Once this code is run, we're left with the same table we had originally:

|Survey|Date       |Site  | Bumblebees | Honeybees | Hoverflies  
|:----:|:---------:|:----:|:----------:|:---------:|:----------:
|1     |10/06/2017 |CO1   |5           |2          |3           
|2     |18/06/2017 |CO2   |4           |1          |0           
|3     |25/06/2017 |CO3   |10          |5          |1           
|4     |05/07/2017 |OP1   |8           |3          |2           
|5     |12/07/2017 |OP2   |3           |2          |5           
|6     |21/07/2017 |OP3   |2           |7          |9           
