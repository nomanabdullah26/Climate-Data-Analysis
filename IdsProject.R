library(tidyverse)
weather <- read.csv("sorted_temp_and_rain_dataset.csv")

# Just look at what you have
head(weather)



##cleaning

# Load required libraries
library(dplyr)
library(tidyr)

# Read the dataset
df <- read.csv('sorted_temp_and_rain_dataset.csv')

# Display initial info
cat("=== INITIAL DATASET INFO ===\n")
cat("Dataset dimensions:", dim(df), "\n")
cat("Columns:", names(df), "\n")
cat("\nMissing values before cleaning:\n")
print(colSums(is.na(df)))
cat("\nData types:\n")
print(sapply(df, class))

# STEP 1: Remove the 'name' column as requested
cat("\n=== STEP 1: REMOVING 'name' COLUMN ===\n")
df_cleaned <- df %>% select(-name)
cat("'name' column removed successfully\n")

# STEP 2: Handle missing values in numeric columns
cat("\n=== STEP 2: HANDLING MISSING VALUES ===\n")

# Check for missing values in key columns
missing_before <- colSums(is.na(df_cleaned[, c('tem', 'rain', 'Month', 'Year')]))
cat("Missing values before treatment:\n")
print(missing_before)

# Handle missing values in Year column
df_cleaned <- df_cleaned %>%
  mutate(Year = ifelse(is.na(Year), 
                       approx(seq_along(Year), Year, seq_along(Year))$y, 
                       Year))

# Handle missing values in Month column (should be 1-12)
df_cleaned <- df_cleaned %>%
  mutate(Month = ifelse(is.na(Month) | Month < 1 | Month > 12, 
                        NA, Month))

# For temperature (tem) - use linear interpolation
df_cleaned <- df_cleaned %>%
  mutate(tem = ifelse(is.na(tem), 
                      approx(seq_along(tem), tem, seq_along(tem))$y, 
                      tem))

# For rainfall (rain) - use linear interpolation
df_cleaned <- df_cleaned %>%
  mutate(rain = ifelse(is.na(rain), 
                       approx(seq_along(rain), rain, seq_along(rain))$y, 
                       rain))

# Remove any remaining rows with NA values
df_cleaned <- df_cleaned %>% drop_na()

cat("\nMissing values after cleaning:\n")
print(colSums(is.na(df_cleaned)))

# STEP 3: OUTLIER DETECTION AND REMOVAL
cat("\n=== STEP 3: OUTLIER DETECTION AND REMOVAL ===\n")

# Calculate outlier bounds using IQR method for rainfall
rain_Q1 <- quantile(df_cleaned$rain, 0.25, na.rm = TRUE)
rain_Q3 <- quantile(df_cleaned$rain, 0.75, na.rm = TRUE)
rain_IQR <- rain_Q3 - rain_Q1
lower_bound <- rain_Q1 - 1.5 * rain_IQR
upper_bound <- rain_Q3 + 1.5 * rain_IQR

cat("Rainfall Outlier Detection:\n")
cat("Q1 (25th percentile):", rain_Q1, "\n")
cat("Q3 (75th percentile):", rain_Q3, "\n")
cat("IQR:", rain_IQR, "\n")
cat("Lower bound:", lower_bound, "\n")
cat("Upper bound:", upper_bound, "\n")

# Identify outliers
rain_outliers <- df_cleaned %>% 
  filter(rain < lower_bound | rain > upper_bound) %>%
  select(Year, Month, rain)

cat("\nIdentified rainfall outliers:\n")
print(rain_outliers)
cat("Number of rainfall outliers:", nrow(rain_outliers), "\n")

# Remove outliers
df_cleaned <- df_cleaned %>% 
  filter(rain >= lower_bound & rain <= upper_bound)

cat("Outliers removed from dataset\n")

# STEP 4: Data validation and quality checks
cat("\n=== STEP 4: DATA VALIDATION ===\n")

# Check for reasonable ranges
cat("Temperature range:", range(df_cleaned$tem, na.rm = TRUE), "\n")
cat("Rainfall range:", range(df_cleaned$rain, na.rm = TRUE), "\n")
cat("Month range:", range(df_cleaned$Month, na.rm = TRUE), "\n")
cat("Year range:", range(df_cleaned$Year, na.rm = TRUE), "\n")

# Check for outliers in temperature (values outside 3 standard deviations)
tem_mean <- mean(df_cleaned$tem, na.rm = TRUE)
tem_sd <- sd(df_cleaned$tem, na.rm = TRUE)
tem_outliers <- sum(abs(df_cleaned$tem - tem_mean) > 3 * tem_sd, na.rm = TRUE)

cat("Potential temperature outliers (>3 SD):", tem_outliers, "\n")

# Check for negative rainfall (impossible values)
negative_rain <- sum(df_cleaned$rain < 0, na.rm = TRUE)
cat("Negative rainfall values:", negative_rain, "\n")

# Fix negative rainfall values
df_cleaned <- df_cleaned %>%
  mutate(rain = ifelse(rain < 0, 0, rain))

# STEP 5: Final dataset info
cat("\n=== FINAL CLEANED DATASET ===\n")
cat("Final dimensions:", dim(df_cleaned), "\n")
cat("Rows removed:", nrow(df) - nrow(df_cleaned), "\n")
cat("\nFirst few rows of cleaned data:\n")
print(head(df_cleaned))

# Summary statistics
cat("\nSummary statistics of cleaned data:\n")
print(summary(df_cleaned))

# Save cleaned dataset
write.csv(df_cleaned, "cleaned_climate_data.csv", row.names = FALSE)
cat("\nCleaned dataset saved as 'cleaned_climate_data.csv'\n")



#Visualization:


# Load required libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(lubridate)

# Read the cleaned dataset (use your cleaned data)
df <- read.csv('cleaned_climate_data.csv')

# Convert to proper date format
df$Date <- as.Date(paste(df$Year, df$Month, "15", sep = "-"))

# ====================
# TIME SERIES PLOTS
# ====================

# 1. Temperature Time Series
p1 <- ggplot(df, aes(x = Date, y = tem)) +
  geom_line(color = "red", alpha = 0.7) +
  geom_smooth(method = "loess", color = "darkred", se = FALSE) +
  labs(title = "Temperature Time Series (1901-2023)",
       x = "Year", 
       y = "Temperature (°C)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

print(p1)

# 2. Rainfall Time Series
p2 <- ggplot(df, aes(x = Date, y = rain)) +
  geom_line(color = "blue", alpha = 0.7) +
  geom_smooth(method = "loess", color = "darkblue", se = FALSE) +
  labs(title = "Rainfall Time Series (1901-2023)",
       x = "Year", 
       y = "Rainfall (mm)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

print(p2)

# 3. Combined Time Series (Dual Y-axis)
p3 <- ggplot(df) +
  geom_line(aes(x = Date, y = tem, color = "Temperature"), alpha = 0.7) +
  geom_line(aes(x = Date, y = rain/20, color = "Rainfall"), alpha = 0.7) +
  scale_y_continuous(
    name = "Temperature (°C)",
    sec.axis = sec_axis(~.*20, name = "Rainfall (mm)")
  ) +
  scale_color_manual(values = c("Temperature" = "red", "Rainfall" = "blue")) +
  labs(title = "Temperature and Rainfall Trends (1901-2023)",
       x = "Year",
       color = "Variable") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "bottom")

print(p3)

# ====================
# SEASONAL ANALYSIS
# ====================

# 4. Seasonal Temperature Pattern (Boxplot by Month)
p4 <- ggplot(df, aes(x = factor(Month), y = tem)) +
  geom_boxplot(fill = "lightcoral", alpha = 0.7) +
  labs(title = "Seasonal Temperature Variation by Month",
       x = "Month", 
       y = "Temperature (°C)") +
  scale_x_discrete(labels = month.abb) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

print(p4)

# 5. Seasonal Rainfall Pattern (Boxplot by Month)
p5 <- ggplot(df, aes(x = factor(Month), y = rain)) +
  geom_boxplot(fill = "lightblue", alpha = 0.7) +
  labs(title = "Seasonal Rainfall Variation by Month",
       x = "Month", 
       y = "Rainfall (mm)") +
  scale_x_discrete(labels = month.abb) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

print(p5)

# 6. Average Monthly Temperature and Rainfall
monthly_avg <- df %>%
  group_by(Month) %>%
  summarise(
    Avg_Temperature = mean(tem, na.rm = TRUE),
    Avg_Rainfall = mean(rain, na.rm = TRUE)
  )

p6 <- ggplot(monthly_avg) +
  geom_line(aes(x = Month, y = Avg_Temperature, color = "Temperature"), size = 1) +
  geom_line(aes(x = Month, y = Avg_Rainfall/10, color = "Rainfall"), size = 1) +
  scale_x_continuous(breaks = 1:12, labels = month.abb) +
  scale_y_continuous(
    name = "Average Temperature (°C)",
    sec.axis = sec_axis(~.*10, name = "Average Rainfall (mm)")
  ) +
  scale_color_manual(values = c("Temperature" = "red", "Rainfall" = "blue")) +
  labs(title = "Average Monthly Temperature and Rainfall Patterns",
       x = "Month",
       color = "Variable") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "bottom")

print(p6)

# 7. Heatmap of Monthly Rainfall Patterns
p7 <- df %>%
  group_by(Year, Month) %>%
  summarise(Avg_Rainfall = mean(rain, na.rm = TRUE)) %>%
  ggplot(aes(x = factor(Month), y = Year, fill = Avg_Rainfall)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "darkblue", 
                      name = "Rainfall (mm)") +
  scale_x_discrete(labels = month.abb) +
  labs(title = "Rainfall Heatmap by Year and Month",
       x = "Month", 
       y = "Year") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 45, hjust = 1))

print(p7)

# 8. Seasonal Decomposition (for last 20 years for clarity)
recent_data <- df %>% filter(Year >= 2000)

p8 <- ggplot(recent_data, aes(x = factor(Month), y = tem, group = Year)) +
  geom_line(aes(color = Year), alpha = 0.6) +
  scale_color_gradient(low = "blue", high = "red") +
  scale_x_discrete(labels = month.abb) +
  labs(title = "Temperature Patterns by Year (2000-2023)",
       x = "Month", 
       y = "Temperature (°C)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

print(p8)

# 9. Monthly Distribution (Violin Plots)
p9 <- ggplot(df, aes(x = factor(Month), y = rain)) +
  geom_violin(fill = "lightblue", alpha = 0.7) +
  labs(title = "Monthly Rainfall Distribution",
       x = "Month", 
       y = "Rainfall (mm)") +
  scale_x_discrete(labels = month.abb) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

print(p9)

# Save all plots
plots <- list(p1, p2, p3, p4, p5, p6, p7, p8, p9)

# Save individual plots
for (i in 1:length(plots)) {
  ggsave(paste0("climate_plot_", i, ".png"), plots[[i]], 
         width = 10, height = 6, dpi = 300)
}

cat("All visualizations completed and saved as PNG files!\n")

# Additional: Summary statistics by season
df <- df %>%
  mutate(Season = case_when(
    Month %in% c(12, 1, 2) ~ "Winter",
    Month %in% c(3, 4, 5) ~ "Spring", 
    Month %in% c(6, 7, 8) ~ "Summer",
    Month %in% c(9, 10, 11) ~ "Autumn"
  ))

seasonal_summary <- df %>%
  group_by(Season) %>%
  summarise(
    Avg_Temperature = mean(tem, na.rm = TRUE),
    Avg_Rainfall = mean(rain, na.rm = TRUE),
    Count = n()
  )

cat("\n=== SEASONAL SUMMARY ===\n")
print(seasonal_summary)




# Load libraries
library(dplyr)
library(ggplot2)

# Read data
df <- read.csv('cleaned_climate_data.csv')

# ====================
# TREND ANALYSIS
# ====================

cat("=== SIMPLE TREND ANALYSIS ===\n\n")

# Temperature trend
temp_trend <- lm(tem ~ Year, data = df)
cat("Temperature Trend:\n")
cat("Change per year:", round(coef(temp_trend)[2], 4), "°C\n")
cat("Change per century:", round(coef(temp_trend)[2] * 100, 3), "°C\n\n")

# Rainfall trend  
rain_trend <- lm(rain ~ Year, data = df)
cat("Rainfall Trend:\n")
cat("Change per year:", round(coef(rain_trend)[2], 4), "mm\n")
cat("Change per century:", round(coef(rain_trend)[2] * 100, 3), "mm\n\n")

# Simple trend plot
ggplot(df, aes(x = Year, y = tem)) +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Simple Temperature Trend", x = "Year", y = "Temperature (°C)") +
  theme_minimal()

ggplot(df, aes(x = Year, y = rain)) +
  geom_smooth(method = "lm", color = "blue") +
  labs(title = "Simple Rainfall Trend", x = "Year", y = "Rainfall (mm)") +
  theme_minimal()

# ====================
# SEASONAL PATTERNS
# ====================

cat("=== SEASONAL PATTERNS ===\n\n")

# Monthly averages
monthly_avg <- df %>%
  group_by(Month) %>%
  summarise(
    Avg_Temp = round(mean(tem), 2),
    Avg_Rain = round(mean(rain), 2)
  )

cat("Average by Month:\n")
print(monthly_avg)

# Seasonal plot
ggplot(monthly_avg, aes(x = Month, y = Avg_Temp)) +
  geom_line(color = "red", size = 1) +
  geom_point(color = "red") +
  scale_x_continuous(breaks = 1:12, labels = month.abb) +
  labs(title = "Average Monthly Temperature", x = "Month", y = "Temperature (°C)") +
  theme_minimal()

ggplot(monthly_avg, aes(x = Month, y = Avg_Rain)) +
  geom_line(color = "blue", size = 1) +
  geom_point(color = "blue") +
  scale_x_continuous(breaks = 1:12, labels = month.abb) +
  labs(title = "Average Monthly Rainfall", x = "Month", y = "Rainfall (mm)") +
  theme_minimal()

# ====================
# CORRELATION
# ====================

cat("=== CORRELATION ANALYSIS ===\n\n")

# Overall correlation
correlation <- cor(df$tem, df$rain)
cat("Overall Correlation (Temperature vs Rainfall):", round(correlation, 3), "\n\n")

# Simple scatter plot
ggplot(df, aes(x = tem, y = rain)) +
  geom_point(alpha = 0.3, color = "purple") +
  geom_smooth(method = "lm", color = "red") +
  labs(title = paste("Temperature vs Rainfall\nCorrelation =", round(correlation, 3)),
       x = "Temperature (°C)", y = "Rainfall (mm)") +
  theme_minimal()

# ====================
# BASIC SUMMARY
# ====================

cat("=== BASIC SUMMARY ===\n\n")
cat("Dataset Period:", min(df$Year), "-", max(df$Year), "\n")
cat("Total Records:", nrow(df), "\n")
cat("Average Temperature:", round(mean(df$tem), 2), "°C\n")
cat("Average Rainfall:", round(mean(df$rain), 2), "mm\n")
cat("Hottest Month:", month.abb[which.max(monthly_avg$Avg_Temp)], "\n")
cat("Wettest Month:", month.abb[which.max(monthly_avg$Avg_Rain)], "\n")