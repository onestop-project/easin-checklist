library(jsonlite)
library(dplyr)
library(purrr)
library(readr)

# Get all species
url <- "https://easin.jrc.ec.europa.eu/apixg/catxg/getall/skip/0/take/99999"
all_species <- jsonlite::fromJSON(
  txt = url,
  simplifyVector = TRUE,
  flatten = TRUE) %>%
  dplyr::tibble()

all_species

# Welke velden?
names(all_species)

# Check values of some fields, e.g. `HasImpact`
unique(all_species$HasImpact)
all_species %>%
  dplyr::filter(HasImpact == TRUE)

# Check values of some fields, e.g. `IsOutermostConcern`
unique(all_species$IsOutermostConcern)
all_species %>%
  dplyr::filter(IsOutermostConcern == TRUE)

# Info about one species
url_single_species <- sprintf("https://easin.jrc.ec.europa.eu/apixg/catxg/easinid/%s",
                              all_species$EasinID[24])
info_single_species <- jsonlite::fromJSON(
  txt = url_single_species,
  simplifyVector = TRUE,
  flatten = TRUE
)
info_single_species
View(info_single_species)


# We create a df with `EASINID` and columns from `CBD_Pathways` column
# df
cbd_pathways <-
  info_single_species$CBD_Pathways[[1]] %>%
  dplyr::mutate(EASINID = info_single_species$EASINID) %>%
  dplyr::relocate(EASINID)
cbd_pathways

# Let's write a function to get all information for a single species/taxon
get_species_info <- function(easin_id) {
  url_single_species <- sprintf("https://easin.jrc.ec.europa.eu/apixg/catxg/easinid/%s",
                                easin_id)
  jsonlite::fromJSON(
    txt = url_single_species,
    simplifyVector = TRUE,
    flatten = TRUE
  ) %>%
    dplyr::as_tibble()
}
# Now we do for all EASINID with purrr
info_easin_species <- purrr::map_df(
  all_species$EasinID[1:1000],
  get_species_info
)
View(info_easin_species)

# Create a data.frame with all EasinID and the unnnested data.frame from the
# specified column
get_col_info <- function(df, col_name) {
  df %>%
    dplyr::select(EASINID, {{col_name}}) %>%
    tidyr::unnest({{col_name}}) %>%
    dplyr::relocate(EASINID)
}
first_introductions <- get_first_introductions(
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

# Save files
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

