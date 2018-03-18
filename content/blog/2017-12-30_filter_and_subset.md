+++
author = "the Anxious Analyst"
categories = ["R"]
tags = ["data tidying", "tidyverse"]
date = "2017-12-30"
description = "How to select only certain records from a data frame"
featured = "dam_laGomera_003.jpg"
featuredalt = "Presa de los Chejelipes, La Gomera"
featuredpath = "/img/blogposts/"
linktitle = ""
title = "Three ways to 'filter' out a 'subset' of records from a data frame in R"
type = "post"
+++

## Introduction

In order to analyse data, a necessary first step is to ensure that you have only those records from a dataset that are relevant to the analysis that you wish to perform. Often certain records need to be removed so that you are only comparing the records that meet a particular set of criteria. Of course, you could go through and delete the records that don't meet the necessary criteria and save a new spreadsheet file with only the relevant records. However, typically it is far quicker and more efficient to keep the entire data table intact and simply cherry-pick the required records from the table.

R offers many methods for extracting only certain records from a data frame. However, the extract operator `[` and the functions `dplyr::filter()` and `base::subset()` comprise three simple and intuitive methods for subsetting a data frame. This article will run through the process of retrieving a subset of all records using these three methods.

I'll start with the extract operator `[` from the 'base' package. 

## Square brackets []

### Syntax

Square brackets can be used to select only certain rows and/or columns from a data frame. The general form of a call using the extract operator looks like this:
```r
dataset[rows,columns]
```
Thus, the name of the original data frame is followed by square brackets which enclose details of the rows and columns to be kept, separated by a comma. Rows are always listed first. In order to apply criteria to the selection of rows from the full data frame, you can use the `which()` function, also from the 'base' package:
```r
dataset[which(dataset$year == 2012),]
```
The same operation can also be performed without either the `which()` function or the `,`. However, omitting the comma is only possible if you are selecting for rows and not trying to subset columns. Hence, the following code should return the same result. I'm not sure whether there are subsetting situations using square brackets where `which` is completely necessary. Please comment on this post if you know of such circumstances.
```r
dataset[dataset$year == 2012]
```
This call would return only those records for which the value of the 'year' column was equal to 2012. The fact that no arguments are listed for the columns means that all columns from the original data frame would be returned. In order to return only columns 1 and 4-7, you would amend the call thusly:
```r
dataset[dataset$year == 2012, c(1, 4:7)]
```
If you wanted to list the columns to include by name rather than index, the call becomes somewhat complicated:
```r
dataset[dataset$year == 2012, names(dataset) %in% c('county','year','population')]
```
This call would return all records from 2012 and only values from the columns 'county', 'year' and 'population' for each record.

Finally, to add multiple criteria to the selection of records you use the logical AND `&` or OR `|` operators:
```r
dataset[dataset$year == 2012 & dataset$county == 'Kent', c(1, 4:7)]
```
Here, all records from Kent in 2012 would be returned, along with only the values stored in columns 1 and 4-7 for each record.


## dplyr::filter()

The ```filter()``` function from the 'dplyr' package takes a data frame and selects from it only those rows that meet the criteria listed in the call to the function. The function returns all columns present in the original data frame. 

### Syntax

The general syntax looks like this:
```r
input_data %>%
  filter(criterion1, criterion2, ...)
```
Therefore, to select only records from Kent in 2012 from an imaginary dataset, you would type the following:
```r
dataset %>%
  filter(year == 2012, county == 'Kent')
```
The code above selects only those records from the data frame called 'dataset' which meet the criteria of having a value of 2012 in the 'year' column and 'Kent' in the 'county' column. Note that variable names do not need quotes nor the name of the data frame where they are found (like ```dataset$year```, as was necessary with the extract operator). 

The criteria for the filtering process can be any relational operation (```>```, ```<```, ```>=```, ```<=```, ```==```, or ```!=```) or combination of relational operations. For example, if you wanted to select only the records from Kent that fell in the year range of 2005 to 2007, then you could simply add a second criteria for the year value to ensure that only records meeting both 'year' criteria are retained:
```r
dataset %>%
  filter(year > 2004, year < 2008, county == 'Kent')
```
This call requires that the value in the 'year' column be both greater than 2004 AND less than 2008. Therefore, only records from Kent with year values of 2005, 2006 and 2007 would be retained.

## base::subset()

The `subset()` function from the 'base' package in R performs essentially the same kind of operations as the `filter()` function. There are a few subtle differences however.

### Syntax

As with the `filter()` function, `subset()` takes a data frame (or matrix or vector) and returns only those rows that meet the criteria specified in the function call:
```r
dataset %>%
  subset(year == 2012 & county == 'Kent')
```
As you can see, `subset()` works almost exactly the same as `filter()`, and indeed, the result of this call is identical to the first code example given at the start of the article. However, notice that there is one important difference in the syntax for `subject()`: rather than separating successive conditions with a comma as before, now a logical operator (AND `&` or OR `|`) is used instead to include multiple conditions in a single call.

Another difference with `subset()` is that it takes an optional argument `select =`, which allows you to return only certain columns from the original data frame. For example, if you'd only like columns 1, and 4-7 in the filtered data frame, then you would type the following:
```r
dataset %>%
  subset(year == 2012 & county == 'Kent', select = c(1, 4:7))
```
The `select =` argument can also be used to exclude columns. Moreover, column names can be used instead of column index numbers if you wish. Therefore, if you wanted to exclude the 'county' column from appearing in the resulting filtered table, then you could enter the following command:
```r
dataset %>%
  subset(year == 2012 & county == 'Kent', select = -county)
```
The same thing can be done for data that has been filtered using the `filter()` function; however, you have to pass the result of the filter call to another function: `dplyr::select()`. Here is an example of how to do the same thing as the call above using `filter()` and `select()`:
```r
dataset %>%
  filer(year == 2012, county == 'Kent') %>%
  select(-county)
```
### Storing a filtered dataset as a new data frame

It's important to remember that the extract operator, `filter()` and `subset()` functions do not make any changes to the original data frame. Therefore, if you want to use the filtered version of a data frame in analyses, then you should store the result of a call to one of the functions in a new variable:
```r
filtered_data1 <- dataset[dataset$year > 2004 & dataset$year < 2008 & 
  dataset$county == 'Kent', c(1,4:7)]

filtered_data2 <- dataset %>%
  filter(year > 2004, year < 2008, county == 'Kent') %>%
  select(c(1,4:7))

filtered_data3 <- dataset %>%
  subset(year > 2004 % year < 2008 & county == 'Kent', select = c(1,4:7))
```
These calls should all produce the same filtered dataset. Now records from Kent between the years of 2005 and 2007 will be stored in a new data frame called 'filtered_data'(1,2 or 3). Meanwhile, the data frame called 'dataset' remains unaltered.

Which method of subsetting looks best to you? I tend to go with `filter()` or occasionally `subset()` because I like having a function name that explicitly states what I'm doing. That said, I'd like to get more fluent with using brackets as they seem to make your code more succinct in many cases.
