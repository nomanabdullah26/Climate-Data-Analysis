Climate Data Analysis: Temperature and Rainfall Trends (1901-2023)
This project performs an Exploratory Data Analysis (EDA) on historical climate data spanning over a century. Using R, the project cleans raw weather data, handles outliers, and generates visualizations to identify long-term trends in temperature and rainfall patterns.

Project Overview
The goal of this analysis is to process a dataset containing monthly temperature and rainfall records from 1901 to 2023. The workflow covers data cleaning, outlier detection using the IQR method, trend analysis, and seasonal decomposition.

Dataset
Input File: sorted_temp_and_rain_dataset.csv

Processed File: cleaned_climate_data.csv

Features:

Year: 1901 to 2023

Month: 1 to 12

tem: Temperature in Celsius

rain: Rainfall in millimeters

Data Processing Pipeline
The analysis is conducted in three main stages:

Data Cleaning:

Removal of unnecessary columns (e.g., name).

Handling missing values using linear interpolation (approx function).

Correction of invalid entries (e.g., negative rainfall values set to 0).

Outlier Detection:

Applied the Interquartile Range (IQR) method to detect anomalies in rainfall data.

Outliers beyond 1.5 * IQR were identified and removed to ensure trend accuracy.

Visualization & Analysis:

Generated time series plots to observe long-term changes.

Created boxplots and violin plots to analyze seasonal distributions.

Calculated correlation between temperature and rainfall.

Visualizations
1. Time Series Trends
The temperature shows a distinct upward trend over the century, while rainfall remains relatively stable with high annual volatility.

https://climate_plot_1.png/
https://climate_plot_2.png/
https://climate_plot_3.png/

2. Seasonal Variations
Analysis of monthly distributions reveals distinct wet and dry seasons. The boxplots and violin plots show the variance in rainfall, highlighting the monsoon months.

https://climate_plot_5.png/
https://climate_plot_9.png/

3. Heatmaps and Annual Patterns
The heatmap illustrates rainfall intensity by year and month, while the line chart tracks temperature patterns for the most recent two decades (2000-2023).

https://climate_plot_7.png/
https://climate_plot_8.png/

Key Findings
Based on the lm() (Linear Model) trend analysis performed in the script:

Temperature Trend: There is a positive correlation between Year and Temperature. The model indicates a warming trend over the century.

Rainfall Trend: The rainfall trend is slightly negative or negligible compared to temperature, indicating that while temperatures are rising, total annual rainfall has not significantly decreased or increased in a linear fashion.

Seasonality:

Hottest Month: Typically peaks in the mid-year months (depending on the specific region data).

Wettest Month: Shows a clear peak, likely corresponding to monsoon seasons.

Requirements
To run this analysis, you need R installed with the following libraries:

r
install.packages(c("dplyr", "tidyr", "ggplot2", "lubridate"))
How to Run
Clone the repository.

Place the sorted_temp_and_rain_dataset.csv in the project directory.

Run the data_cleaning.R script to generate the cleaned dataset.

Run the visualization.R script to generate the plots and statistical summaries.
