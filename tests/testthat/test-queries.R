# Unit tests for query helper functions
# Mirrors the Python test suite in wildbook-python-client/tests/test_queries.py

library(testthat)
library(jsonlite)

# Test Basic Queries ----

test_that("match_all returns correct structure", {
  query <- match_all()
  expect_type(query, "list")
  expect_true("match_all" %in% names(query))

  # Verify it serializes to correct JSON
  json <- toJSON(query, auto_unbox = TRUE)
  expect_match(json, '\\{"match_all":\\{\\}\\}')
})

test_that("filter_by_sex creates correct query", {
  query <- filter_by_sex("female")
  expect_equal(query, list(term = list(sex = "female")))
})

test_that("filter_by_individual creates correct query", {
  uuid <- "123e4567-e89b-12d3-a456-426614174000"
  query <- filter_by_individual(uuid)
  expect_equal(query, list(term = list(individualId = uuid)))
})

test_that("filter_by_submitter creates correct query", {
  uuid <- "user-uuid"
  query <- filter_by_submitter(uuid)
  expect_equal(query, list(term = list(submitterID = uuid)))
})

# Test Species Queries ----

test_that("filter_by_species with genus only searches taxonomy and genus", {
  query <- filter_by_species("Megaptera")
  expect_true("bool" %in% names(query))
  expect_true("should" %in% names(query$bool))
  expect_equal(query$bool$minimum_should_match, 1)
  expect_equal(length(query$bool$should), 2)

  # Should contain a wildcard on taxonomy and a term on genus
  has_taxonomy <- any(sapply(query$bool$should, function(x) {
    !is.null(x$wildcard$taxonomy$value) &&
      x$wildcard$taxonomy$value == "Megaptera *"
  }))
  expect_true(has_taxonomy)

  has_genus <- any(sapply(query$bool$should, function(x) {
    identical(x, list(term = list(genus = "Megaptera")))
  }))
  expect_true(has_genus)
})

test_that("filter_by_species with genus and epithet searches taxonomy and separate fields", {
  query <- filter_by_species("Megaptera", "novaeangliae")
  expect_true("bool" %in% names(query))
  expect_true("should" %in% names(query$bool))
  expect_equal(query$bool$minimum_should_match, 1)
  expect_equal(length(query$bool$should), 2)

  # Should contain a terms query on taxonomy with the concatenated string
  has_taxonomy <- any(sapply(query$bool$should, function(x) {
    identical(x, list(terms = list(taxonomy = list("Megaptera novaeangliae"))))
  }))
  expect_true(has_taxonomy)

  # Should contain a bool/must with genus and specificEpithet terms
  has_separate <- any(sapply(query$bool$should, function(x) {
    !is.null(x$bool$must) &&
      length(x$bool$must) == 2 &&
      any(sapply(x$bool$must, function(t) identical(t, list(term = list(genus = "Megaptera"))))) &&
      any(sapply(x$bool$must, function(t) identical(t, list(term = list(specificEpithet = "novaeangliae")))))
  }))
  expect_true(has_separate)
})

# Test Year Range Queries ----

test_that("filter_by_year_range with both start and end", {
  query <- filter_by_year_range(2020, 2023)
  expect_equal(query, list(
    range = list(
      year = list(
        gte = 2020,
        lte = 2023
      )
    )
  ))
})

test_that("filter_by_year_range with start only", {
  query <- filter_by_year_range(start_year = 2020)
  expect_equal(query, list(
    range = list(
      year = list(
        gte = 2020
      )
    )
  ))
})

test_that("filter_by_year_range with end only", {
  query <- filter_by_year_range(end_year = 2023)
  expect_equal(query, list(
    range = list(
      year = list(
        lte = 2023
      )
    )
  ))
})

# Test Location Queries ----

test_that("filter_by_location with country", {
  query <- filter_by_location(country = "Kenya")
  expect_equal(query, list(term = list(country = "Kenya")))
})

test_that("filter_by_location with location_id", {
  query <- filter_by_location(location_id = "loc-123")
  expect_equal(query, list(term = list(locationId = "loc-123")))
})

test_that("filter_by_location with bounding box", {
  query <- filter_by_location(
    min_lat = -5.0,
    max_lat = 5.0,
    min_lon = 35.0,
    max_lon = 42.0
  )
  expect_true("geo_bounding_box" %in% names(query))
  expect_equal(query$geo_bounding_box$location$top_left, list(lat = 5.0, lon = 35.0))
  expect_equal(query$geo_bounding_box$location$bottom_right, list(lat = -5.0, lon = 42.0))
})

test_that("filter_by_location with multiple parameters", {
  query <- filter_by_location(
    country = "Kenya",
    min_lat = -5.0,
    max_lat = 5.0,
    min_lon = 35.0,
    max_lon = 42.0
  )
  expect_true("bool" %in% names(query))
  expect_true("must" %in% names(query$bool))
  expect_equal(length(query$bool$must), 2)
})

test_that("filter_by_location with no parameters returns match_all", {
  query <- filter_by_location()
  expect_equal(query, match_all())
})

# Test Text Search ----

test_that("text_search simple query", {
  query <- text_search("verbatimLocality", "beach")
  expect_true("match" %in% names(query))
  expect_equal(query$match$verbatimLocality, "beach")
})

test_that("text_search fuzzy query", {
  query <- text_search("verbatimLocality", "beach", fuzzy = TRUE)
  expect_true("fuzzy" %in% names(query))
  expect_equal(query$fuzzy$verbatimLocality$value, "beach")
  expect_equal(query$fuzzy$verbatimLocality$fuzziness, "AUTO")
})

# Test Existence Queries ----

test_that("field_exists creates correct query", {
  query <- field_exists("individualId")
  expect_equal(query, list(exists = list(field = "individualId")))
})

test_that("field_missing creates correct query", {
  query <- field_missing("individualId")
  expect_true("bool" %in% names(query))
  expect_true("must_not" %in% names(query$bool))
  expect_equal(query$bool$must_not, list(list(exists = list(field = "individualId"))))
})

# Test Query Combination ----

test_that("combine_queries with no queries returns match_all", {
  query <- combine_queries()
  expect_equal(query, match_all())
})

test_that("combine_queries with single query returns that query", {
  sex_query <- filter_by_sex("female")
  query <- combine_queries(sex_query)
  expect_equal(query, sex_query)
})

test_that("combine_queries with must operator (AND)", {
  sex_query <- filter_by_sex("female")
  year_query <- filter_by_year_range(2020, 2023)
  query <- combine_queries(sex_query, year_query, operator = "must")

  expect_true("bool" %in% names(query))
  expect_true("must" %in% names(query$bool))
  expect_equal(length(query$bool$must), 2)

  # Check that both queries are in the must list
  has_sex <- any(sapply(query$bool$must, function(x) identical(x, sex_query)))
  expect_true(has_sex)

  has_year <- any(sapply(query$bool$must, function(x) identical(x, year_query)))
  expect_true(has_year)
})

test_that("combine_queries with should operator (OR)", {
  sex_query <- filter_by_sex("female")
  year_query <- filter_by_year_range(2020, 2023)
  query <- combine_queries(sex_query, year_query, operator = "should")

  expect_true("bool" %in% names(query))
  expect_true("should" %in% names(query$bool))
  expect_equal(length(query$bool$should), 2)
})

test_that("combine_queries with must_not operator (NOT)", {
  sex_query <- filter_by_sex("unknown")
  year_query <- filter_by_year_range(end_year = 2000)
  query <- combine_queries(sex_query, year_query, operator = "must_not")

  expect_true("bool" %in% names(query))
  expect_true("must_not" %in% names(query$bool))
  expect_equal(length(query$bool$must_not), 2)
})

test_that("combine_queries with single query returns unchanged regardless of operator", {
  sex_query <- filter_by_sex("female")

  # Single query should return unchanged, operator is ignored
  query1 <- combine_queries(sex_query, operator = "must")
  expect_equal(query1, sex_query)

  query2 <- combine_queries(sex_query, operator = "should")
  expect_equal(query2, sex_query)
})
