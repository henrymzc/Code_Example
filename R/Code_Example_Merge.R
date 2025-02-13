# ==== Setup ====
rm(list=ls())  # Clear environment
knitr::opts_chunk$set(echo = TRUE)

# Load necessary libraries
library(tidyverse)
library(lubridate)
library(data.table)

# Load helper functions
source("~/Dropbox/Research/Judge_Bail/judge_model/judge_model/code/clean/replication/helper_functions.R")
source("~/Dropbox/Research/Judge_Bail/judge_model/judge_model/code/clean/replication/helper_functionsV2.R")

# ==== Load Branch 1 Data ====
# Read Branch 1 data, which includes defendants and cases
b1df <- fread("~/Dropbox/Research/Judge_Bail/judge_model/judge_model/data/output/b1_and_defs.csv.gz")

# Merge with additional case details
b1df <- b1df %>%
  left_join(
    fread("~/Dropbox/Research/Judge_Bail/judge_model/judge_model/data/output/cases.csv.gz", 
          select = c("case_row_id", "in_arrest", "in_crime", "CPD")) %>%
      tibble(),
    by = "case_row_id"
  )

# Convert date variables to date format
b1df <- b1df %>%
  mutate_at(vars(contains("date")), ymd) %>%
  mutate(diff_cid_b1 = as.numeric(date) - as.numeric(case_init_date)) %>%
  arrange(DID, fcb, case_init_date) %>%
  group_by(DID, fcb) %>%
  mutate(
    in_crime = max(replace_na(in_crime, 0)),
    in_arrest = max(replace_na(in_arrest, 0)),
    CPD = max(replace_na(CPD, 0)),
    min_diff_cid_b1 = min(diff_cid_b1),
    max_diff_cid_b1 = max(diff_cid_b1),
    n_b1_cases = n()
  ) %>%
  filter(row_number() == 1) %>% 
  ungroup()

# Apply filtering conditions for valid cases
b1df <- b1df %>%
  filter(
    case_init_date >= "2008-03-01" & case_init_date <= "2017-08-31",
    between(diff_cid_b1, 0, 2),
    between(min_diff_cid_b1, 0, 2)
  )

# ==== Add Initial Charges for Analysis ====
b1df <- b1df %>%
  select(-starts_with("charge_")) %>%
  inner_join(
    fread("~/Dropbox/Research/Judge_Bail/judge_model/judge_model/data/output/charges_and_outcomes_by_cases.csv.gz") %>%
      tibble() %>%
      select(case_number, DID, fcb, starts_with("charge_")) %>%
      select(-contains("charge_sentence")),
    by = c("case_number", "DID", "fcb")
  )

# ==== Identify Cases with "C" or "CR" Designations ====
caselink <- fread("~/Dropbox/Research/Judge_Bail/judge_model/judge_model/data/output/DID_case_link.csv.gz") %>%
  select(DID, fcb, case_number, case_row_id)

has_ccr <- caselink %>%
  group_by(DID, fcb) %>%
  summarise(
    has_cr = as.numeric(any(grepl("CR", case_number))),
    has_c = as.numeric(any(grepl("C[0-9]", case_number))),
    n_cases = n()
  ) %>%
  ungroup()

# Merge this information into the main dataset
b1df <- inner_join(b1df, has_ccr, by = c("DID", "fcb"))
rm(has_ccr)

# ==== Merge Case Outcomes ====
caseoutcomes <- fread("~/Dropbox/Research/Judge_Bail/judge_model/judge_model/data/output/case_outcomes.csv.gz") %>%
  tibble() %>%
  select(-contains("next_")) %>%
  inner_join(
    b1df %>%
      select(DID, fcb) %>%
      unique(),
    by = c("DID", "fcb")
  )

# Aggregate case-level outcomes at the defendant level
caseoutcomes <- caseoutcomes %>%
  left_join(
    fread("~/Dropbox/Research/Judge_Bail/judge_model/judge_model/data/output/charges_and_outcomes_by_cases.csv.gz") %>%
      tibble() %>%
      select(DID, fcb, starts_with("guilty_"), starts_with("charge_sentence")) %>%
      group_by(DID, fcb) %>%
      summarise_all(max) %>%
      ungroup(),
    by = c("DID", "fcb")
  )

# ==== Merge Event-Based Disposition Codes ====
case_events <- fread("~/Dropbox/Research/Judge_Bail/judge_model/judge_model/data/output/docket_events.csv.gz") %>%
  inner_join(caselink %>% select(case_row_id, case_number, fcb, DID)) %>%
  inner_join(b1df %>% select(DID, fcb, b1date = date)) %>%
  arrange(DID, fcb, date)

# Create binary indicators for key disposition codes
dispo_codes <- c(
  "0913" = "ddt_code",   # Defendant demands trial
  "0890" = "dic_code",   # Defendant in custody
  "0914" = "dnic_code",  # Defendant not in court
  "0701" = "warrissued_code",  # Warrant issued
  "0997" = "warrsentpa_code",  # Warrant sent to police agency
  "0277" = "emiorder_code",    # EMI ordered
  "0901" = "pubdef_code",      # Public defender
  "0986" = "aattabsent_code",  # Admonished as to trial in absentia
  "0278" = "emsher_code",      # EM sheriff
  "0353" = "petprobviol_code", # Petition probation violation
  "0800" = "fcfpd_code",       # Fines, costs, fees per draft order
  "0892" = "donem_code",       # Defendant on electronic monitoring system
  "0279" = "notadmitem_code",  # Not admit / EM-Bail set to stand
  "0630" = "bondforfeit_code"  # Bond forfeited
)

for (code in names(dispo_codes)) {
  case_events[[dispo_codes[[code]]]] <- as.numeric(case_events$disposition_code == code)
}

# Aggregate indicators at the defendant level
code_any <- case_events %>%
  filter(date > b1date) %>%
  select(DID, fcb, contains("_code")) %>%
  group_by(DID, fcb) %>%
  summarise_all(max) %>%
  ungroup() %>%
  rename_with(~ gsub("_code", "_anycode", .))

code_sum <- case_events %>%
  filter(date > b1date) %>%
  select(DID, fcb, contains("_code")) %>%
  group_by(DID, fcb) %>%
  summarise_all(sum) %>%
  ungroup() %>%
  rename_with(~ gsub("_code", "_sumcode", .))

# Merge aggregated indicators into `b1df`
b1df <- b1df %>%
  left_join(code_any, by = c("DID", "fcb")) %>%
  left_join(code_sum, by = c("DID", "fcb")) %>%
  mutate_at(vars(matches("_anycode|_sumcode")), ~replace_na(., 0))

rm(code_any, code_sum, case_events)

# ==== Save Processed Data ====
saveRDS(b1df, "~/Dropbox/Research/Judge_Bail/judge_model/judge_model/data/output/full_data.rds")
