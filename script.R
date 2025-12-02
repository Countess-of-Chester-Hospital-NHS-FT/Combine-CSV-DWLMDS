#import libraries 
library(tidyverse)
library(janitor)
library(odbc)
library(DBI)

set_theme(theme_bw())

# List folders in outer folder
outer_folder <- "S:\\Finance & Performance\\IM&T\\BIReporting\\Corporate Reporting (Trust Level)\\External Returns\\Diagnostic WLMDS"

folder_names <- list.files(path = outer_folder) |> 
  as_tibble() |>
  rename(folder = value) |>
  filter(nchar(folder) == 8)

inner_folders <- nrow(folder_names)
distinct_folders <- folder_names |> distinct(folder) |> nrow()

file_names <- tibble()

# Loop through inner folders and add inner filenames to the dataframe
for (i in 1:inner_folders) {
  folder_name <- folder_names$folder[i]
  path <- paste0(outer_folder, "\\", folder_name)
  
  temp_df <- list.files(path = path) |>
    as_tibble() |>
    rename(filename = value) |>
    mutate(folder = folder_name)
  
  file_names <- bind_rows(file_names, temp_df)
  
}

# filter to the files of interest
file_names_filtered <- file_names |>
  filter(str_detect(filename, pattern = 'Diagnostic WLMDS \\d{8}.csv')) |>
  mutate(date = str_extract(filename, pattern = '\\d{8}'),
         date = dmy(date),
         weekday = wday(date, label = TRUE)) |>
  arrange(date)

# combine files into single csv
files_to_combine <- nrow(file_names_filtered)
combined_df <- tibble()

for (i in 1:files_to_combine) {
  foldername <- file_names_filtered$folder[i]
  filename <- file_names_filtered$filename[i]
  path <- paste0(outer_folder, "\\", foldername, "\\", filename)
  
  temp_df <- read_csv(path) |>
    mutate(Referral_Identifier = as.character(Referral_Identifier))
  
  combined_df <- bind_rows(combined_df, temp_df)
}

# dq check of output

summary_df <- combined_df |>
  mutate(Week_Ending_Date = dmy(Week_Ending_Date)) |>
  group_by(Week_Ending_Date) |>
  summarise(n = n())

# all the dates I am expecting
submission_dates <- seq(from = ymd("20250302"), to = today() - weeks(1), by = "1 week") |>
  as_tibble() |>
  rename(date = value) |>
  left_join(summary_df, by = c("date" = "Week_Ending_Date"))

# plot the data
submission_dates |>
  ggplot(aes(x = date, y = n)) +
  geom_line() +
  geom_point() +
  labs(y = "Number of rows",
       title = "Diagnostic waiting list size")

if (min(submission_dates$n) < 7500 | max(submission_dates$n) > 12000) {
  stop("Missing or duplicated data detected - check submission_dates table")
}

# Tidy up table ready for import
combined_df <- combined_df |>
  select(-starts_with("...")) |>
  mutate(Week_Ending_Date = dmy(Week_Ending_Date),
         combined_date = today()) |>
  filter(Week_Ending_Date %in% submission_dates$date)

# Convert dates
combined_df <- combined_df |>
  mutate(across(c(PERSON_BIRTH_DATE, 
                  REFERRAL_TO_TREATMENT_PERIOD_START_DATE,
                  Diagnostic_Clock_Start_Date,
                  Planned_Diagnostic_Due_Date), dmy)) |>
  mutate(DATE_AND_TIME_DATA_SET_CREATED = dmy_hms(DATE_AND_TIME_DATA_SET_CREATED))

############### Write data to the database #####################################
#stop("Temp stop") # for development

# Connect to the database
con <- dbConnect(odbc::odbc(), 
                 DSN = "coch_p2",
                 Database = "InformationSandpitDB")

# Write table to database
dbWriteTable(con, 
             name = Id(schema = "Reports", table = "Diagnostic_WLMDS_Combined"),
             value = combined_df,
             overwrite = TRUE)

# Close the connection when finished
dbDisconnect(con)

  
  
