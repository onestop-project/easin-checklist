library(jsonlite)
library(dplyr)

# Get all species
url <- "https://easin.jrc.ec.europa.eu/apixg/catxg/getall/skip/0/take/15000"
all_species <- jsonlite::fromJSON(
  txt = url,
  simplifyVector = TRUE,
  flatten = TRUE) %>%
  dplyr::tibble()

# Info about one species
url_single_species <- sprintf("https://easin.jrc.ec.europa.eu/apixg/catxg/easinid/%s",
                              easin_species$EasinID[1])
info_single_species <- fromJSON(
  txt = url_single_species,
  simplifyVector = TRUE,
  flatten = TRUE
)
info_single_species
View(info_single_species)

# Get alien species (implement rough basic pagination)
status <- "A" # Other values: 'C' Cryptogenic or 'Q' Questionable
skip <- 0 # records to skip
n <- 1000 # records to ask
continue <- TRUE
url <- sprintf(
  "https://easin.jrc.ec.europa.eu/apixg/catxg/status/%s/skip/%s/take/%s",
  status,
  skip,
  n
)
alien_species_chunk <- jsonlite::fromJSON(
  txt = url,
  simplifyVector = TRUE,
  flatten = TRUE) %>%
  dplyr::tibble()
alien_species <- alien_species_chunk
while (continue == TRUE) {
  skip <- skip + nrow(alien_species_chunk)
  url <- sprintf(
    "https://easin.jrc.ec.europa.eu/apixg/catxg/status/%s/skip/%s/take/%s",
    status,
    skip,
    n
  )
  alien_species_chunk <- jsonlite::fromJSON(
    txt = url,
    simplifyVector = TRUE,
    flatten = TRUE) %>%
    dplyr::tibble()
  if ("Empty" %in% names(alien_species_chunk)) {
    continue <- FALSE
  } else {
    if (nrow(alien_species_chunk) < n) {
      continue <- FALSE
    }
    alien_species <- dplyr::bind_rows(alien_species, alien_species_chunk)
  }
}
alien_species
