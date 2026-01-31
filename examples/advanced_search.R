# Advanced Search Examples for RWildbook
#
# This example demonstrates:
# - Complex search queries
# - Filtering by multiple criteria
# - Using helper functions
# - Pagination through results

library(RWildbook)

# Helper for NULL coalescing
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

# Configuration - credentials will be automatically picked up from environment variables
# WILDBOOK_URL, WILDBOOK_USERNAME, WILDBOOK_PASSWORD

# Create client
cat("Creating Wildbook client...\n")
client <- WildbookClient$new(Sys.getenv("WILDBOOK_URL", "http://localhost:8080"))

tryCatch({
  cat("Attempting to log in...\n")
  client$login()  # Uses environment variables
  cat("✓ Logged in\n\n")

  # Example 1: Search by sex and year range
  cat(strrep("=", 60), "\n")
  cat("Example 1: Female encounters from 2020-2023\n")
  cat(strrep("=", 60), "\n")

  sex_query <- filter_by_sex("female")
  year_query <- filter_by_year_range(2020, 2023)

  combined <- combine_queries(sex_query, year_query, operator = "must")
  results <- client$search_encounters(combined, size = 5)

  cat(sprintf("Found %d encounters\n", length(results$hits)))
  if (length(results$hits) > 0) {
    for (i in seq_along(results$hits[1:min(3, length(results$hits))])) {
      hit <- results$hits[[i]]
      cat(sprintf("\n%d. Encounter %s\n", i, hit$id %||% "N/A"))
      genus <- hit$genus %||% "Unknown"
      species <- hit$specificEpithet %||% ""
      cat(sprintf("   Species: %s\n", trimws(paste(genus, species))))
      cat(sprintf("   Sex: %s\n", hit$sex %||% "Unknown"))
      cat(sprintf("   Date: %s/%s/%s\n",
                  hit$year %||% "?",
                  hit$month %||% "?",
                  hit$day %||% "?"))
      cat(sprintf("   Location: %s\n", hit$verbatimLocality %||% "N/A"))
    }
  } else {
    cat("   No female encounters found in that date range\n")
  }
  cat("\n")

  # Example 2: Search by location
  cat(strrep("=", 60), "\n")
  cat("Example 2: Encounters in Kenya\n")
  cat(strrep("=", 60), "\n")

  # Try to find encounters - use country from your database
  # You can change 'Kenya' to match countries in your database
  location_query <- filter_by_location(country = "Kenya")
  results <- client$search_encounters(location_query, size = 5)

  cat(sprintf("Found %d encounters in Kenya\n", length(results$hits)))
  if (length(results$hits) > 0) {
    for (i in seq_along(results$hits[1:min(3, length(results$hits))])) {
      hit <- results$hits[[i]]
      genus <- hit$genus %||% "Unknown"
      species <- hit$specificEpithet %||% ""
      cat(sprintf("\n%d. %s\n", i, trimws(paste(genus, species))))
      cat(sprintf("   Location: %s\n", hit$verbatimLocality %||% "N/A"))
      cat(sprintf("   Coordinates: %s, %s\n",
                  hit$decimalLatitude %||% "N/A",
                  hit$decimalLongitude %||% "N/A"))
    }
  } else {
    cat("   No encounters found for that country\n")
    cat("   Try changing the country name to match your database\n")
  }
  cat("\n")

  # Example 3: Find unassigned encounters
  cat(strrep("=", 60), "\n")
  cat("Example 3: Encounters without assigned individuals\n")
  cat(strrep("=", 60), "\n")

  unassigned_query <- field_missing("individualId")
  results <- client$search_encounters(unassigned_query, size = 5)

  cat(sprintf("Found %d unassigned encounters\n", length(results$hits)))
  if (length(results$hits) > 0) {
    for (i in seq_along(results$hits[1:min(3, length(results$hits))])) {
      hit <- results$hits[[i]]
      cat(sprintf("\n%d. Encounter %s\n", i, hit$id %||% "N/A"))
      genus <- hit$genus %||% "Unknown"
      species <- hit$specificEpithet %||% ""
      cat(sprintf("   Species: %s\n", trimws(paste(genus, species))))
      cat(sprintf("   Has annotations: %s\n",
                  ifelse(length(hit$annotations %||% list()) > 0, "Yes", "No")))
    }
  } else {
    cat("   All encounters have assigned individuals\n")
  }
  cat("\n")

  # Example 4: Text search in locality field
  cat(strrep("=", 60), "\n")
  cat("Example 4: Text search for specific location\n")
  cat(strrep("=", 60), "\n")

  # Search for encounters with locality information
  # Note: Change search term to match localities in your database
  text_query <- text_search("verbatimLocality", "beach", fuzzy = TRUE)
  results <- client$search_encounters(text_query, size = 5)

  cat(sprintf("Found %d encounters matching 'beach'\n", length(results$hits)))
  if (length(results$hits) > 0) {
    for (i in seq_along(results$hits[1:min(3, length(results$hits))])) {
      hit <- results$hits[[i]]
      cat(sprintf("\n%d. %s\n", i, hit$verbatimLocality %||% "N/A"))
      genus <- hit$genus %||% "Unknown"
      species <- hit$specificEpithet %||% ""
      cat(sprintf("   Species: %s\n", trimws(paste(genus, species))))
    }
  } else {
    cat("   No matches found\n")
    cat("   Try a different search term that matches your data\n")
  }
  cat("\n")

  # Example 5: Paginating through results
  cat(strrep("=", 60), "\n")
  cat("Example 5: Pagination example\n")
  cat(strrep("=", 60), "\n")

  query <- match_all()
  page_size <- 10
  total_to_fetch <- 25

  all_encounters <- list()
  page_num <- 0

  repeat {
    from_offset <- page_num * page_size
    cat(sprintf("Fetching page %d (offset: %d)...\n", page_num + 1, from_offset))

    results <- client$search_encounters(query, from = from_offset, size = page_size)
    hits <- results$hits

    all_encounters <- c(all_encounters, hits)

    if (length(hits) < page_size || length(all_encounters) >= total_to_fetch) {
      if (length(hits) < page_size) {
        cat("Reached last page\n")
      }
      break
    }

    page_num <- page_num + 1
  }

  cat(sprintf("\nFetched %d total encounters across %d pages\n",
              length(all_encounters), page_num + 1))
  cat("\n")

  # Example 6: Search individuals
  cat(strrep("=", 60), "\n")
  cat("Example 6: Searching for individuals\n")
  cat(strrep("=", 60), "\n")

  # Search for individuals with assigned encounters
  has_encounters <- field_exists("encounters")
  results <- client$search_individuals(has_encounters, size = 5)

  cat(sprintf("Found %d individuals with encounters\n", length(results$hits)))
  if (length(results$hits) > 0) {
    for (i in seq_along(results$hits[1:min(3, length(results$hits))])) {
      hit <- results$hits[[i]]
      cat(sprintf("\n%d. Individual %s\n", i, hit$id %||% "N/A"))
      cat(sprintf("   Name: %s\n", hit$displayName %||% "Unnamed"))
      cat(sprintf("   Encounters: %d\n", length(hit$encounters %||% list())))
    }
  } else {
    cat("   No individuals found\n")
  }
  cat("\n")

}, error = function(e) {
  cat(sprintf("\n✗ Error: %s\n", e$message))
  traceback()
}, finally = {
  if (client$is_authenticated()) {
    cat("\nLogging out...\n")
    client$logout()
  }
})

cat("Done!\n")
