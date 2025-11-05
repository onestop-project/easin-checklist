library(reasin)
library(dplyr)
library(purrr)
library(readr)

# Get all species ####
all_species <- get_species()
all_species

# Example: get info one species
info_single_species <- get_species(all_species$EasinID[1])
info_single_species

# Get info for all species ####
info_easin_species <- get_species(all_species$EasinID)
info_easin_species

# Get all info from some nested columns ####

# Create a data.frame with all EasinID and the unnnested data.frame from the
# specified column
get_col_info <- function(df, col_name) {
  df %>%
    dplyr::select(EASINID, {{col_name}}) %>%
    tidyr::unnest({{col_name}}) %>%
    dplyr::relocate(EASINID)
}


first_introductions <- get_col_info(
  info_easin_species,
  "FirstIntroductionsInEU"
)
first_introductions

presences_in_countries<- get_col_info(
  info_easin_species,
  "PresentInCountries"
)
presences_in_countries

cbd_pathways <- get_col_info(info_easin_species, "CBD_Pathways")
cbd_pathways

native_ranges <- get_col_info(info_easin_species, "NativeRange")
native_ranges

# Save files ####
readr::write_csv(
  info_easin_species,
  "data/raw/info_easin_species.csv",
  na = ""
)
readr::write_csv(
  first_introductions,
  "data/raw/first_introductions.csv",
  na = ""
)
readr::write_csv(
  presences_in_countries,
  "data/raw/presences_in_countries.csv",
  na = ""
)
readr::write_csv(
  cbd_pathways,
  "data/raw/cbd_pathways.csv",
  na = ""
)
readr::write_csv(
  native_ranges,
  "data/raw/native_ranges.csv",
  na = ""
)
