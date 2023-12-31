Google Capstone Project: Case Study 1
================

## Backstory

The eighth and final module of the Google Data Analytics Certificate
requires the completion of a case study. This story is a breakdown of
Case Study \#1.

The marketing director at Cyclistic, a bike-share company wants to
maximize the number of annual memberships as they are more profitable.
The director also believes the best approach is to convert casual riders
into members. Casual riders are riders who use single-ride or full-day
passes, members are riders with an annual subscription.

## Answering the Business Question

The process will be broken down into the 6 key steps of Data Analysis:
Ask, Prepare, Process, Analyse, Share(Findings) and Act(Recommendation).

### Ask

The business question assigned to me: understand the behavior of members
and casual riders.

### Prepare

Memory constraints limited me to 4 data sets - the first quarter of
2023. Data is sourced from
<https://divvy-tripdata.s3.amazonaws.com/index.html> . All the work in
this project was done in Rstudio.

### Process

Upon inspection of the columns, they all included:

- **ride_id**: unique key for each trip

- **rideable_type**: the type of bike used

- **started_at**: time the trip started

- **ended_at**: time the trip ended

- **start_station_name** and **end_station_name**: name of the starting
  and ending stations respectively

- **end_station_id** and **start_station_id**: unique key for each
  station

- **end_lat** and **end_long:** latitude and longitude for each station

- **member_casual**: the user’s membership type

Libraries used

``` r
library(dplyr)
library(readxl)
library(skimr)
library(ggplot2)
library(lubridate)
library(scales)
```

Merging Datasets

``` r
X2023_Q1 <- rbind(X202301, X202302, X202303, X202304) #combine datasets
X2023_Q1 <- read.csv("2023_Q1.CSV") #Case SenSitivE
str(X2023_Q1) #quick summary of new dataset
rm(X202304, X202303, X202302, X202301) #remove from environment to save memory
```

Adding new columns

``` r
X2023_Q1$date <- as.Date(X2023_Q1$started_at)
X2023_Q1$month <- format(as.Date(X2023_Q1$date), "%m")
X2023_Q1$day <- format(as.Date(X2023_Q1$date), "%d")
X2023_Q1$week_day <- wday(X2023_Q1$date, label = TRUE, abbr = FALSE)
format(as.Date(X2023_Q1$date), "%A")
X2023_Q1$ride_length <-
  difftime(X2023_Q1$ended_at, X2023_Q1$started_at)
```

Removing empty rows

``` r
X2023_Q1 <- X2023_Q1 %>%
  drop_na()
nrow(X2023_Q1)
```

Finding and ensuring there are no duplicates

``` r
unique(X2023_Q1$member_casual)
unique(X2023_Q1$rideable_type)
sum(duplicated((X2023_Q1$ride_id)))
```

### Analyze

No visualisations included because Rstudio goes to sleep anytime the
Knitter is run.

#### Amount of full members and casuals

``` r
member_count_perc <- X2023_Q1 %>% 
  group_by(member_casual) %>% 
  summarise(n=n()) %>% 
  mutate(percentage = signif(n*100/sum(n),2))
```

``` r
ggplot(data = member_count_perc, aes(x="", y=percentage, fill=member_casual)) + geom_bar(width = 1, stat = "identity") + coord_polar("y", start = 0) + geom_text(aes(label=paste0(percentage, "%")),size=6, position = position_stack(vjust = .5)) + theme_void()+ labs(fill="Membership Type", title = "Members vs Casuals")
```

Code has to be in-line and continuous, else I would have stacked all the
plot layers line by line.

#### Most active days

``` r
busiest_days <- X2023_Q1 %>% 
  group_by(week_day) %>% 
  summarise(n=n())
```

``` r
ggplot(busiest_days, aes(x = week_day, y=n)) + geom_bar(position = "dodge", stat = "identity") + labs(title = "Busiest Days",fill='Membership Type', x="Weekday", y="Rides Booked") + scale_y_continuous(labels = label_number(scale = 1e-3, suffix = "K"))
```

`scale_y_continuous(labels = label_number(scale = 1e-3, suffix = "K")`

This fixes the y-axis using exponential as its scale.

#### Daily ride behavior

``` r
avg_ride_length <- X2023_Q1 %>%
  group_by(member_casual, week_day) %>%
  summarise(n = mean(ride_length) / 60)
```

``` r
ggplot(avg_ride_length, aes(fill = member_casual, x = week_day, y = n)) + geom_bar(position = "dodge", stat = "identity") + labs(title = "Average Ride Times per Weekday", fill = "Membership Type",x = "Weekday",y = "Average Ride Length (minutes)")
```

#### Monthly ride behavior

``` r
rides_per_month <- X2023_Q1 %>%
  group_by(month, member_casual) %>%
  summarise(n = n())
```

``` r
ggplot(data = rides_per_month, aes(x = month, fill = member_casual, y=n)) + geom_bar(position = "dodge", stat = "identity") + labs(title = "Monthly Ride Behaviour", fill = "Membership Type", x = 'Month', y = 'Total Rides')
```

#### Popular bikes by users

``` r
bikes_by_membership <- X2023_Q1 %>%
  group_by(member_casual, rideable_type) %>%
  summarise(n = n()) %>%
  mutate(percentage = n * 100 / sum(n))
```

``` r
ggplot(
  data = bikes_by_membership,
  mapping = aes(x = member_casual, y = n, fill = rideable_type)) + geom_col() + labs(title = "Bikes booked by Users") + geom_text(aes(label = n), position = position_stack(vjust = 0.5)) + labs(fill="Bikes") + scale_y_continuous(labels = label_number(scale = 1e-3, suffix = "K"))
```

#### Ride length by bikes

``` r
avg_bike_length2 <- X2023_Q1 %>%
  group_by(rideable_type, member_casual) %>%
  summarise(n = signif(mean(ride_length / 60), digits = 3))
```

``` r
ggplot(avg_bike_length2, aes(fill = rideable_type, x = member_casual, y = n)) + geom_bar(position = "dodge", stat = "identity") + labs(title = "Average Ride Length by Bike", fill = "Membership Type", x = "Membership Type", y = "Average Ride Length(minutes)")
```

#### Mean time spent on bike

``` r
avg_bike_length <- X2023_Q1 %>%
  group_by(rideable_type) %>%
  summarise(n = signif(mean(ride_length / 60), digits = 3))
```

``` r
ggplot(avg_bike_length, aes(fill = rideable_type, x = rideable_type, y = n)) + geom_bar(position = "dodge", stat = "identity") + geom_text(aes(label = n), position = position_stack(vjust = 0.5)) + labs(title = "Average Ride Length by Bike", fill = "Membership Type", x = "Bike Type", y = "Average Ride Length (minutes)")
```

The visualisations are located in [this Medium
story](https://medium.com/@jerryade75/google-data-analytics-capstone-project-6647ad9abdaf "Click to see visualisations"),
including the Recommendations too.
