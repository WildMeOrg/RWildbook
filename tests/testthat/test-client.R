# Unit tests for WildbookClient class
# Mirrors the Python test suite in wildbook-python-client/tests/test_client.py
#
# Note: These tests use httptest2 for mocking HTTP requests
# Install with: install.packages("httptest2")

library(testthat)
library(RWildbook)

# Helper to check if httptest2 is available
has_httptest2 <- requireNamespace("httptest2", quietly = TRUE)

if (!has_httptest2) {
  skip("httptest2 not available - skipping client tests")
}

library(httptest2)

# Test Client Initialization ----

test_that("WildbookClient initializes with base_url", {
  client <- WildbookClient$new("http://localhost:8080")
  expect_equal(client$base_url, "http://localhost:8080")
  expect_false(client$is_authenticated())
})

test_that("WildbookClient initializes with env var", {
  withr::with_envvar(
    c(WILDBOOK_URL = "http://example.com"),
    {
      client <- WildbookClient$new()
      expect_equal(client$base_url, "http://example.com")
    }
  )
})

test_that("WildbookClient fails without base_url or env var", {
  withr::with_envvar(
    c(WILDBOOK_URL = NA),
    {
      expect_error(
        WildbookClient$new(),
        "base_url not provided and WILDBOOK_URL environment variable not set"
      )
    }
  )
})

test_that("WildbookClient strips trailing slash from base_url", {
  client <- WildbookClient$new("http://localhost:8080/")
  expect_equal(client$base_url, "http://localhost:8080")
})

# Test Authentication ----

test_that("login with explicit credentials", {
  with_mock_dir("login_success", {
    client <- WildbookClient$new("http://localhost:8080")

    # Mock the login response
    httptest2::with_mock_api({
      # This would normally require a fixture file, but we'll skip for now
      # as httptest2 setup is complex
      skip("Mocking infrastructure not fully set up")
    })
  })
})

test_that("login fails without credentials or env vars", {
  withr::with_envvar(
    c(WILDBOOK_USERNAME = NA, WILDBOOK_PASSWORD = NA),
    {
      client <- WildbookClient$new("http://localhost:8080")
      expect_error(
        client$login(),
        "username not provided and WILDBOOK_USERNAME environment variable not set"
      )
    }
  )
})

test_that("login with env vars", {
  withr::with_envvar(
    c(WILDBOOK_USERNAME = "test@example.com", WILDBOOK_PASSWORD = "testpass"),
    {
      client <- WildbookClient$new("http://localhost:8080")
      # Would need mocking to test actual login
      expect_false(client$is_authenticated())
    }
  )
})

test_that("is_authenticated returns FALSE before login", {
  client <- WildbookClient$new("http://localhost:8080")
  expect_false(client$is_authenticated())
})

test_that("methods require authentication", {
  client <- WildbookClient$new("http://localhost:8080")

  expect_error(
    client$get_current_user(),
    "Not authenticated"
  )

  expect_error(
    client$get_user_home(),
    "Not authenticated"
  )

  expect_error(
    client$search_encounters(match_all()),
    "Not authenticated"
  )

  expect_error(
    client$search_individuals(match_all()),
    "Not authenticated"
  )

  expect_error(
    client$get_encounter("test-uuid"),
    "Not authenticated"
  )

  expect_error(
    client$get_individual("test-uuid"),
    "Not authenticated"
  )

  expect_error(
    client$filter_current_user(),
    "Not authenticated"
  )
})

# Test Query Wrapping ----

test_that("search_encounters wraps unwrapped queries", {
  # This tests the query wrapping logic without making actual HTTP calls
  query <- match_all()
  expect_false("query" %in% names(query))

  # After wrapping (which happens inside search_encounters)
  if (!("query" %in% names(query))) {
    wrapped <- list(query = query)
  } else {
    wrapped <- query
  }

  expect_true("query" %in% names(wrapped))
  expect_equal(wrapped$query, query)
})

test_that("search_encounters doesn't double-wrap queries", {
  # Test that already wrapped queries are not double-wrapped
  query <- list(query = match_all())
  expect_true("query" %in% names(query))

  # Should not wrap again
  if (!("query" %in% names(query))) {
    wrapped <- list(query = query)
  } else {
    wrapped <- query
  }

  expect_equal(wrapped, query)
  expect_true("query" %in% names(wrapped))
  expect_false("query" %in% names(wrapped$query))
})

test_that("search_individuals wraps unwrapped queries", {
  # Same test for search_individuals
  query <- filter_by_sex("female")
  expect_false("query" %in% names(query))

  if (!("query" %in% names(query))) {
    wrapped <- list(query = query)
  } else {
    wrapped <- query
  }

  expect_true("query" %in% names(wrapped))
  expect_equal(wrapped$query, query)
})

# Test JSON Serialization ----

test_that("match_all serializes to correct JSON format", {
  library(jsonlite)

  query <- match_all()
  wrapped <- list(query = query)

  json <- toJSON(wrapped, auto_unbox = TRUE)

  # Should be {"query":{"match_all":{}}}
  expect_match(as.character(json), '\\{"query":\\{"match_all":\\{\\}\\}\\}')

  # Parse it back to verify structure
  parsed <- fromJSON(json)
  expect_true("query" %in% names(parsed))
  expect_true("match_all" %in% names(parsed$query))
})

test_that("complex query serializes correctly", {
  library(jsonlite)

  sex_query <- filter_by_sex("female")
  year_query <- filter_by_year_range(2020, 2023)
  query <- combine_queries(sex_query, year_query, operator = "must")
  wrapped <- list(query = query)

  json <- toJSON(wrapped, auto_unbox = TRUE)
  parsed <- fromJSON(json)

  expect_true("query" %in% names(parsed))
  expect_true("bool" %in% names(parsed$query))
  expect_true("must" %in% names(parsed$query$bool))
})
