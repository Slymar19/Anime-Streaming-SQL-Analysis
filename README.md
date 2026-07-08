# Anime Streaming Analysis Using SQL

## Project Overview
This project demonstrates SQL data cleaning and exploratory data analysis on a synthetic anime streaming dataset.

The objective was to transform raw streaming data into a clean analytical dataset and uncover insights related to:

- Anime format performance
- Production studio performance
- Top-performing anime titles
- Genre combination popularity
- Episode length patterns
- Streaming outliers

## Tools Used
- MySQL
- SQL
- CTEs
- Window Functions
- Aggregate Functions

## Dataset Overview

The dataset contains information about anime titles, including:

| Column | Description |
|---|---|
| Anime_Title | Anime title |
| Media_Type | Anime or Movie |
| Primary_Genre | Combined genre categories |
| Episodes | Number of episodes |
| Release_Year | Release year |
| User_Rating | Rating score |
| Global_Streams_Millions | Streaming figures |
| Production_Studio | Production studio |

## Data Cleaning Process

The cleaning workflow included:

- Removing duplicate records using ROW_NUMBER()
- Standardising text columns
- Handling missing values
- Converting incorrect data types
- Validating numerical ranges
- Removing unrealistic values
- Performing final duplicate verification

## Exploratory Data Analysis

### 1. Anime Format Performance

Compared anime series and movies based on:

- Average streams
- Average user ratings

![Anime Format Performance](Images/format_performance.png) 

### 2. Studio Performance

Analysed:

- Number of titles
- Average ratings
- Total streams

![Studio Performance](Images/studio_analysis.png) 

### 3. Top Performing Titles

Identified titles with the highest streaming numbers.


![Top Titles](Images/top_titles.png)


### 4. Genre Combination Analysis

Note: Genre values are stored as combined categories, therefore this analysis evaluates genre combinations rather than individual genres.

Top-performing combinations:

1. Shonen, Action
2. Fantasy, Adventure
3. Shonen, Adventure


![Genre Analysis](Images/genre_analysis.png)


## SQL Files

The repository contains:

- `01_Data_Cleaning.sql`
- `02_Exploratory_Data_Analysis.sql`


## Key Insights

- Anime-format content achieved higher average streams compared to movies.
- A-1 Pictures accumulated the highest total streams.
- A small number of titles acted as significant streaming outliers.
- Action-oriented genre combinations showed strong streaming performance.
