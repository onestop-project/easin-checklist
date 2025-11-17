library(readr)
library(rgbif)
library(dplyr)

# Get species from EASIN Catalogue Database as saved in `info_easin_species.csv`
easin_taxa <- readr::read_csv(
  file = "data/raw/info_easin_species.csv",
  na = ""
)

# Create scientific name column based on columns `Name` and `Authorship`
easin_taxa <- easin_taxa %>%
  dplyr::mutate(scientificName = paste(Name, Authorship)) %>%
  # Remove trailing spaces
  dplyr::mutate(
    scientificName = stringr::str_trim(scientificName)
)

# Check taxa against GBIF Backbone
easin_taxa <- rgbif::name_backbone_checklist(
  name = easin_taxa,
  strict = TRUE
  ) %>%
  # Rename the original columns, returned with prefix `verbatim`, using prefix `easin_`
  dplyr::rename_with(
    .cols = dplyr::starts_with("verbatim"),
    .fn = ~ stringr::str_replace(.x, pattern = "verbatim", replacement = "easin")
  ) %>%
  # Add prefix `gbif_` to all other columns
  dplyr::rename_with(
    .cols = -dplyr::starts_with("easin"),
    .fn = ~ paste0("gbif_", .x)
  )

# Get taxa matching strictly, i.e. no higher rank or fuzzy matches
easin_taxa_matched_backbone <- easin_taxa %>%
  dplyr::filter(!is.na(gbif_usageKey)) %>%
  dplyr::filter(gbif_matchType == "EXACT")

# How many taxa?
nrow(easin_taxa_matched_backbone)

# Percentage
nrow(easin_taxa_matched_backbone) / nrow(easin_taxa) * 100


# Get taxa from temporary European checklist of invasive alien species
# (permalink to specific version used!)
eu_taxa <- readr::read_csv(
  file = "https://raw.githubusercontent.com/onestop-project/unified-europe/825abc1e52fc8e619ac0ff2ea926f7550892a083/data/Europe/taxon.csv",
  na = ""
)

# Column `id` (or `taxonID`) contain taxon IDs from GBIF Backbone. Notice that
# if there is no match to backbone, the id is equal to
# `"https://www.gbif.org/species/NA"`.

# Taxa in eu_taxa matching the GBIF Backbone
eu_taxa_matched_backbone <- eu_taxa %>%
  dplyr::filter(!stringr::str_ends(id, pattern = "/NA"))

# How many taxa?
nrow(eu_taxa_matched_backbone)

# Percentage
nrow(eu_taxa_matched_backbone) / nrow(eu_taxa) * 100

# Compare EASIN taxa with EU taxa. We have to ignore the
# `https://www.gbif.org/species/` prefix from column `id`. How many taxa in
# `easin_taxa` are present in `eu_taxa`?
easin_in_eu <- easin_taxa %>%
  dplyr::filter(
    gbif_usageKey %in%
      stringr::str_remove(eu_taxa$id, pattern = "https://www.gbif.org/species/")
)

# How many taxa from EASIN Catalogue are present in draft EU list?
nrow(easin_in_eu)

# Percentage
nrow(easin_in_eu) / nrow(easin_taxa) * 100

# Compare EU taxa with EASIN taxa. How many taxa in `eu_taxa` are present in
# `easin_taxa`?
eu_in_easin <- eu_taxa %>%
  dplyr::filter(
    stringr::str_remove(id, pattern = "https://www.gbif.org/species/") %in%
      easin_taxa$gbif_usageKey
)

# How many taxa from draft EU list are present in EASIN Catalogue?
nrow(eu_in_easin)

# Percentage
nrow(eu_in_easin) / nrow(eu_taxa) * 100


# If we consider only the taxa from EASIN Catalogue that matched to GBIF
# Backbone, how many of them are taxa matching to GBIF Backbone
# from the draft EU list?
easin_in_eu_matched <- easin_taxa_matched_backbone %>%
  dplyr::filter(
    gbif_usageKey %in%
      stringr::str_remove(eu_taxa$id, pattern = "https://www.gbif.org/species/")
)

# How many taxa from EASIN Catalogue matched to GBIF Backbone are present in
# draft EU list?
nrow(easin_in_eu_matched)

# Percentage (referring to the EASIN Catalogue taxa with a match to GBIF
# Backbone)
nrow(easin_in_eu_matched) / nrow(easin_taxa_matched_backbone) * 100

# If we consider only the taxa from draft EU list that matched to GBIF Backbone,
# how many of them are taxa matching to GBIF Backbone from the EASIN Catalogue?
eu_in_easin_matched <- eu_taxa_matched_backbone %>%
  dplyr::filter(
    stringr::str_remove(id, pattern = "https://www.gbif.org/species/") %in%
      easin_taxa$gbif_usageKey
)

# How many taxa from draft EU list matched to GBIF Backbone are present in
# EASIN Catalogue?
nrow(eu_in_easin_matched)
# Percentage (referring to the EU taxa list with a match to GBIF Backbone)
nrow(eu_in_easin_matched) / nrow(eu_taxa_matched_backbone) * 100
