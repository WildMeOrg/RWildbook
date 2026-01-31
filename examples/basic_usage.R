# Basic Usage Example for RWildbook
#
# This example demonstrates:
# - Creating a client instance
# - Logging in with environment variables
# - Searching for encounters
# - Logging out

library(RWildbook)

# Configuration - credentials will be automatically picked up from environment variables
# WILDBOOK_URL, WILDBOOK_USERNAME, WILDBOOK_PASSWORD

# Create client instance
# The client will use WILDBOOK_URL environment variable if not provided
cat("Creating Wildbook client...\n")
client <- WildbookClient$new(Sys.getenv("WILDBOOK_URL", "http://localhost:8080"))

tryCatch({
  # Login
  # Credentials will be read from WILDBOOK_USERNAME and WILDBOOK_PASSWORD environment variables
  cat("Attempting to log in...\n")
  user_info <- client$login()
  cat(sprintf("✓ Logged in successfully\n"))
  cat(sprintf("  User ID: %s\n", user_info$id))
  cat(sprintf("  Full Name: %s\n", user_info$fullName))
  cat("\n")

  # Get user dashboard
  cat("Fetching user dashboard...\n")
  dashboard <- client$get_user_home()
  cat(sprintf("✓ Latest encounters: %d\n", length(dashboard$latestEncounters)))
  cat(sprintf("  Projects: %d\n", length(dashboard$projects)))
  cat("\n")

  # Search for encounters - get first 10
  cat("Searching for encounters (first 10)...\n")
  query <- match_all()
  results <- client$search_encounters(query, size = 10)

  hits <- results$hits
  cat(sprintf("✓ Found %d encounters\n", length(hits)))
  cat("\n")

  # Display first few encounters
  if (length(hits) > 0) {
    cat("First encounter details:\n")
    first <- hits[[1]]
    cat(sprintf("  ID: %s\n", first$id %||% "N/A"))
    genus <- first$genus %||% "Unknown"
    species <- first$specificEpithet %||% ""
    cat(sprintf("  Species: %s\n", trimws(paste(genus, species))))
    cat(sprintf("  Year: %s\n", first$year %||% "N/A"))
    cat(sprintf("  Location: %s\n", first$verbatimLocality %||% "N/A"))
    cat("\n")
  } else {
    cat("  No encounters found\n\n")
  }

}, error = function(e) {
  cat(sprintf("✗ Error: %s\n", e$message))
}, finally = {
  # Always logout when done
  if (client$is_authenticated()) {
    cat("\nLogging out...\n")
    client$logout()
  }
})

cat("Done!\n")

# Helper function for NULL coalescing
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
