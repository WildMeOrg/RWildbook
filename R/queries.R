#' Query Helper Functions
#'
#' @description
#' Helper functions for constructing common Wildbook search queries using
#' OpenSearch/Elasticsearch query syntax.
#'
#' @name queries
NULL

#' Create Empty JSON Object
#'
#' @description
#' Internal helper to create an empty list that serializes to {} instead of []
#' in JSON. This is needed because OpenSearch expects objects, not arrays.
#'
#' @return An empty named list that serializes to JSON object {}
#' @keywords internal
empty_json_object <- function() {
  setNames(list(), character(0))
}

#' Match All Query
#'
#' @description
#' Create a query that matches all documents
#'
#' @return A query list
#' @export
#' @examples
#' query <- match_all()
match_all <- function() {
  list(match_all = empty_json_object())
}

#' Filter by Sex
#'
#' @description
#' Create a query to filter by sex
#'
#' @param sex Sex value (e.g., "male", "female", "unknown")
#' @return A query list
#' @export
#' @examples
#' query <- filter_by_sex("female")
filter_by_sex <- function(sex) {
  list(term = list(sex = sex))
}

#' Filter by Species
#'
#' @description
#' Create a query to filter by species (genus and specific epithet)
#'
#' @param genus Genus name
#' @param specific_epithet Specific epithet (optional)
#' @return A query list
#' @export
#' @examples
#' # Filter by genus and species
#' query <- filter_by_species("Megaptera", "novaeangliae")
#'
#' # Filter by genus only
#' query <- filter_by_species("Megaptera")
filter_by_species <- function(genus, specific_epithet = NULL) {
  if (!is.null(specific_epithet)) {
    list(
      bool = list(
        must = list(
          list(term = list(genus = genus)),
          list(term = list(specificEpithet = specific_epithet))
        )
      )
    )
  } else {
    list(term = list(genus = genus))
  }
}

#' Filter by Year Range
#'
#' @description
#' Create a query to filter by year range
#'
#' @param start_year Minimum year (inclusive), optional
#' @param end_year Maximum year (inclusive), optional
#' @return A query list
#' @export
#' @examples
#' # Encounters from 2020 to 2023
#' query <- filter_by_year_range(2020, 2023)
#'
#' # Encounters from 2020 onwards
#' query <- filter_by_year_range(start_year = 2020)
filter_by_year_range <- function(start_year = NULL, end_year = NULL) {
  range_query <- list()

  if (!is.null(start_year)) {
    range_query$gte <- start_year
  }
  if (!is.null(end_year)) {
    range_query$lte <- end_year
  }

  list(range = list(year = range_query))
}

#' Filter by Location
#'
#' @description
#' Create a query to filter by location (country, location ID, or bounding box)
#'
#' @param country Country name (optional)
#' @param location_id Location ID (optional)
#' @param min_lat Minimum latitude for bounding box (optional)
#' @param max_lat Maximum latitude for bounding box (optional)
#' @param min_lon Minimum longitude for bounding box (optional)
#' @param max_lon Maximum longitude for bounding box (optional)
#' @return A query list
#' @export
#' @examples
#' # Filter by country
#' query <- filter_by_location(country = "Kenya")
#'
#' # Filter by bounding box
#' query <- filter_by_location(
#'   min_lat = -5.0, max_lat = 5.0,
#'   min_lon = 35.0, max_lon = 42.0
#' )
filter_by_location <- function(country = NULL, location_id = NULL,
                               min_lat = NULL, max_lat = NULL,
                               min_lon = NULL, max_lon = NULL) {
  filters <- list()

  if (!is.null(country)) {
    filters <- c(filters, list(list(term = list(country = country))))
  }

  if (!is.null(location_id)) {
    filters <- c(filters, list(list(term = list(locationId = location_id))))
  }

  if (!is.null(min_lat) && !is.null(max_lat) &&
      !is.null(min_lon) && !is.null(max_lon)) {
    filters <- c(filters, list(list(
      geo_bounding_box = list(
        location = list(
          top_left = list(lat = max_lat, lon = min_lon),
          bottom_right = list(lat = min_lat, lon = max_lon)
        )
      )
    )))
  }

  if (length(filters) == 0) {
    return(match_all())
  } else if (length(filters) == 1) {
    return(filters[[1]])
  } else {
    return(list(bool = list(must = filters)))
  }
}

#' Filter by Individual
#'
#' @description
#' Create a query to find all encounters for a specific individual
#'
#' @param individual_id Individual UUID
#' @return A query list
#' @export
#' @examples
#' query <- filter_by_individual("123e4567-e89b-12d3-a456-426614174000")
filter_by_individual <- function(individual_id) {
  list(term = list(individualId = individual_id))
}

#' Combine Queries
#'
#' @description
#' Combine multiple queries using boolean logic
#'
#' @param ... Query lists to combine
#' @param operator Boolean operator: "must" (AND), "should" (OR), or "must_not" (NOT)
#' @return A combined query list
#' @export
#' @examples
#' # Female humpback whales from 2020-2023
#' species <- filter_by_species("Megaptera", "novaeangliae")
#' sex <- filter_by_sex("female")
#' years <- filter_by_year_range(2020, 2023)
#'
#' query <- combine_queries(species, sex, years, operator = "must")
combine_queries <- function(..., operator = "must") {
  queries <- list(...)

  if (length(queries) == 0) {
    return(match_all())
  } else if (length(queries) == 1) {
    return(queries[[1]])
  }

  bool_query <- list()
  bool_query[[operator]] <- queries

  list(bool = bool_query)
}

#' Text Search
#'
#' @description
#' Create a text search query
#'
#' @param field Field name to search
#' @param text Text to search for
#' @param fuzzy Whether to use fuzzy matching (default: FALSE)
#' @return A query list
#' @export
#' @examples
#' # Search for "beach" in locality
#' query <- text_search("verbatimLocality", "beach")
#'
#' # Fuzzy search
#' query <- text_search("verbatimLocality", "beach", fuzzy = TRUE)
text_search <- function(field, text, fuzzy = FALSE) {
  if (fuzzy) {
    query <- list()
    query[[field]] <- list(value = text, fuzziness = "AUTO")
    list(fuzzy = query)
  } else {
    query <- list()
    query[[field]] <- text
    list(match = query)
  }
}

#' Field Exists
#'
#' @description
#' Create a query to find documents where a field exists and has a value
#'
#' @param field Field name
#' @return A query list
#' @export
#' @examples
#' # Find encounters with an assigned individual
#' query <- field_exists("individualId")
field_exists <- function(field) {
  list(exists = list(field = field))
}

#' Field Missing
#'
#' @description
#' Create a query to find documents where a field is missing or null
#'
#' @param field Field name
#' @return A query list
#' @export
#' @examples
#' # Find encounters without an assigned individual
#' query <- field_missing("individualId")
field_missing <- function(field) {
  list(
    bool = list(
      must_not = list(
        list(exists = list(field = field))
      )
    )
  )
}

#' Filter by Submitter
#'
#' @description
#' Create a query to find encounters submitted by a specific user
#'
#' @param submitter_id User UUID
#' @return A query list
#' @export
#' @examples
#' query <- filter_by_submitter("user-uuid-here")
filter_by_submitter <- function(submitter_id) {
  list(term = list(submitterID = submitter_id))
}
