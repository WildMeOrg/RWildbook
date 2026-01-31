# RWildbook: R Client for Wildbook v3 API

An R package for interacting with the Wildbook v3 API. This package provides an interface for authenticating with Wildbook instances and searching for encounters, individuals, and other data.

## Features

- 🔐 Session-based authentication with automatic cookie management
- 🔍 Powerful search capabilities using OpenSearch/Elasticsearch queries
- 🛠️ Helper functions for common query patterns
- 🎯 Simple, intuitive API similar to tidyverse conventions

## Installation

### From source

```r
# Install dependencies first
install.packages(c("httr2", "jsonlite", "R6"))

# Install from local directory
install.packages("path/to/RWildbook", repos = NULL, type = "source")
```

### Load the package

```r
library(RWildbook)
```

## Quick Start

```r
library(RWildbook)

# Create a client instance
# The base URL can also be set via the WILDBOOK_URL environment variable
client <- WildbookClient$new(Sys.getenv("WILDBOOK_URL", "http://localhost:8080"))

# Login
# Credentials can be passed directly or sourced from WILDBOOK_USERNAME and WILDBOOK_PASSWORD environment variables
client$login()

# Search for encounters
query <- match_all()
results <- client$search_encounters(query, size = 10)

# Print results
for (encounter in results$hits) {
  cat(sprintf("%s: %s %s\n",
              encounter$id,
              encounter$genus,
              encounter$specificEpithet %||% ""))
}

# Logout when done
client$logout()
```

## Authentication

The client uses session-based authentication. After logging in, the session cookie is automatically managed for all subsequent requests. For security, it is highly recommended to use environment variables for sensitive credentials.

```r
# Create client
# The base URL can also be set via the WILDBOOK_URL environment variable
client <- WildbookClient$new(Sys.getenv("WILDBOOK_URL", "http://localhost:8080"))

# Login using environment variables (recommended)
# Credentials sourced from WILDBOOK_USERNAME and WILDBOOK_PASSWORD environment variables
user_info <- client$login()
# Logged in successfully as: user@example.com

# Or login with explicit credentials
user_info <- client$login("user@example.com", "password")

cat(sprintf("User ID: %s\n", user_info$id))
cat(sprintf("Full Name: %s\n", user_info$fullName))

# Check authentication status
if (client$is_authenticated()) {
  cat("✓ Authenticated\n")
}

# Get current user info
user <- client$get_current_user()

# Logout
client$logout()
```

## Searching Encounters

### Basic Search

```r
# Get all encounters
results <- client$search_encounters(match_all(), size = 50)

# With pagination
results <- client$search_encounters(
  match_all(),
  from = 0,        # offset
  size = 20,       # page size
  sort = "year",   # sort field
  sort_order = "desc"
)
```

### Filtering by Species

```r
# Search for humpback whales
query <- filter_by_species("Megaptera", "novaeangliae")
results <- client$search_encounters(query)

# Search by genus only
query <- filter_by_species("Megaptera")
results <- client$search_encounters(query)
```

### Filtering by Date Range

```r
# Encounters from 2020 to 2023
query <- filter_by_year_range(start_year = 2020, end_year = 2023)
results <- client$search_encounters(query)

# Encounters from 2020 onwards
query <- filter_by_year_range(start_year = 2020)
results <- client$search_encounters(query)
```

### Filtering by Location

```r
# Filter by country
query <- filter_by_location(country = "Kenya")
results <- client$search_encounters(query)

# Filter by bounding box
query <- filter_by_location(
  min_lat = -5.0,
  max_lat = 5.0,
  min_lon = 35.0,
  max_lon = 42.0
)
results <- client$search_encounters(query)
```

### Combining Multiple Filters

```r
# Female humpback whales from 2020-2023
species <- filter_by_species("Megaptera", "novaeangliae")
sex <- filter_by_sex("female")
years <- filter_by_year_range(2020, 2023)

query <- combine_queries(species, sex, years, operator = "must")
results <- client$search_encounters(query)
```

### Finding Unassigned Encounters

```r
# Encounters without an assigned individual
query <- field_missing("individualId")
unassigned <- client$search_encounters(query)
```

### Text Search

```r
# Search for "beach" in locality descriptions
query <- text_search("verbatimLocality", "beach", fuzzy = TRUE)
results <- client$search_encounters(query)
```

## Searching Individuals

```r
# Find individuals with encounters
query <- field_exists("encounters")
results <- client$search_individuals(query, size = 20)

for (individual in results$hits) {
  cat(sprintf("%s: %s\n",
              individual$id,
              individual$displayName %||% "Unnamed"))
}
```

## Getting Specific Records

```r
# Get a specific encounter by UUID
encounter <- client$get_encounter("123e4567-e89b-12d3-a456-426614174000")
print(encounter)

# Get a specific individual by UUID
individual <- client$get_individual("987fcdeb-51a2-43f7-9876-543210fedcba")
print(individual)
```

## User Dashboard

```r
# Get dashboard data for the current user
dashboard <- client$get_user_home()

cat(sprintf("Latest encounters: %d\n", length(dashboard$latestEncounters)))
cat(sprintf("Projects: %d\n", length(dashboard$projects)))
```

## Available Query Helpers

The package provides these helper functions for constructing queries:

- `match_all()` - Match all documents
- `filter_by_sex(sex)` - Filter by sex
- `filter_by_species(genus, specific_epithet = NULL)` - Filter by species
- `filter_by_year_range(start_year, end_year)` - Filter by year range
- `filter_by_location(country, location_id, min_lat, max_lat, min_lon, max_lon)` - Filter by location
- `filter_by_individual(individual_id)` - Find encounters for an individual
- `filter_by_submitter(submitter_id)` - Filter by submitter
- `text_search(field, text, fuzzy = FALSE)` - Text search in a field
- `field_exists(field)` - Find documents where field exists
- `field_missing(field)` - Find documents where field is missing
- `combine_queries(..., operator = "must")` - Combine multiple queries with AND/OR/NOT logic

## Custom Queries

For advanced use cases, you can construct your own OpenSearch/Elasticsearch queries:

```r
# Custom query using Elasticsearch DSL
custom_query <- list(
  bool = list(
    must = list(
      list(term = list(genus = "Tursiops")),
      list(range = list(year = list(gte = 2020, lte = 2023)))
    ),
    must_not = list(
      list(term = list(sex = "unknown"))
    )
  )
)

results <- client$search_encounters(custom_query)
```

## Working with Results

Results are returned as R lists. You can convert them to data frames for easier analysis:

```r
library(dplyr)
library(purrr)

# Search for encounters
query <- match_all()
results <- client$search_encounters(query, size = 100)

# Convert to data frame
encounters_df <- map_dfr(results$hits, function(hit) {
  tibble(
    id = hit$id %||% NA,
    genus = hit$genus %||% NA,
    species = hit$specificEpithet %||% NA,
    year = hit$year %||% NA,
    sex = hit$sex %||% NA,
    locality = hit$verbatimLocality %||% NA,
    lat = hit$decimalLatitude %||% NA,
    lon = hit$decimalLongitude %||% NA
  )
})

# Analyze
encounters_df %>%
  group_by(genus, species) %>%
  summarise(count = n()) %>%
  arrange(desc(count))
```

## Error Handling

The client provides clear error messages for different scenarios:

```r
# Handle authentication errors
tryCatch({
  client$login("user@example.com", "wrong_password")
}, error = function(e) {
  cat("Login failed:", e$message, "\n")
})

# Handle not found errors
tryCatch({
  encounter <- client$get_encounter("invalid-uuid")
}, error = function(e) {
  cat("Error:", e$message, "\n")
})

# Always logout in finally block
tryCatch({
  # ... do work ...
}, finally = {
  if (client$is_authenticated()) {
    client$logout()
  }
})
```

## Examples

See the `examples/` directory for complete examples:

- `basic_usage.R` - Basic login, search, and logout
- `advanced_search.R` - Complex queries, pagination, and filtering

Run examples:

```bash
# Set environment variables
export WILDBOOK_URL="http://localhost:8080"
export WILDBOOK_USERNAME="your@email.com"
export WILDBOOK_PASSWORD="yourpassword"

# Run in R
Rscript examples/basic_usage.R
Rscript examples/advanced_search.R
```

## Development

### Package Structure

```
RWildbook/
├── R/
│   ├── client.R              # WildbookClient R6 class
│   └── queries.R             # Query helper functions
├── man/                      # Roxygen2-generated documentation
├── examples/
│   ├── basic_usage.R
│   └── advanced_search.R
├── tests/                    # Test files
├── DESCRIPTION              # Package metadata
├── NAMESPACE               # Package exports
└── README.md
```

### Building Documentation

```r
# Install roxygen2
install.packages("roxygen2")

# Generate documentation
roxygen2::roxygenize()
```

### Running Tests

```r
# Install testthat
install.packages("testthat")

# Run tests
testthat::test_dir("tests")
```

## API Reference

### WildbookClient Class

R6 class for interacting with Wildbook.

#### Methods

- `$new(base_url)` - Create a new client instance
- `$login(username, password)` - Authenticate user
- `$logout()` - End session
- `$is_authenticated()` - Check authentication status
- `$get_current_user()` - Get current user info
- `$get_user_home()` - Get user dashboard data
- `$search_encounters(query, from = 0, size = 10, sort = NULL, sort_order = NULL)` - Search encounters
- `$get_encounter(encounter_id)` - Get specific encounter
- `$search_individuals(query, from = 0, size = 10, sort = NULL, sort_order = NULL)` - Search individuals
- `$get_individual(individual_id)` - Get specific individual

## Requirements

- R >= 4.0.0
- httr2 >= 1.0.0
- jsonlite >= 1.8.0
- R6 >= 2.5.0

## License

[MIT License](LICENSE.md) 

## Support

For issues and questions:
- GitHub Issues: https://github.com/WildMeOrg/RWildbook/issues
- Wildbook Documentation: https://docs.wildme.org/

## Related Projects

- [Wildbook](https://github.com/WildMeOrg/Wildbook) - The main Wildbook platform

## Acknowledgments

Built with:
- [httr2](https://httr2.r-lib.org/) - HTTP client
- [R6](https://r6.r-lib.org/) - Object-oriented programming
- [jsonlite](https://cran.r-project.org/package=jsonlite) - JSON parsing
