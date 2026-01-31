# Basic tests for query helper functions
# Run with: testthat::test_file("tests/test_queries.R")

library(testthat)
library(RWildbook)

test_that("match_all creates correct query", {
  query <- match_all()
  expect_equal(query, list(match_all = list()))
})

test_that("filter_by_sex creates correct query", {
  query <- filter_by_sex("female")
  expect_equal(query, list(term = list(sex = "female")))
})

test_that("filter_by_species with both parameters", {
  query <- filter_by_species("Megaptera", "novaeangliae")
  expect_true("bool" %in% names(query))
  expect_equal(length(query$bool$must), 2)
})

test_that("filter_by_species with genus only", {
  query <- filter_by_species("Megaptera")
  expect_equal(query, list(term = list(genus = "Megaptera")))
})

test_that("filter_by_year_range creates correct query", {
  query <- filter_by_year_range(2020, 2023)
  expect_true("range" %in% names(query))
  expect_equal(query$range$year$gte, 2020)
  expect_equal(query$range$year$lte, 2023)
})

test_that("combine_queries with multiple queries", {
  q1 <- filter_by_sex("female")
  q2 <- filter_by_year_range(2020, 2023)

  combined <- combine_queries(q1, q2, operator = "must")

  expect_true("bool" %in% names(combined))
  expect_equal(length(combined$bool$must), 2)
})

test_that("field_exists creates correct query", {
  query <- field_exists("individualId")
  expect_equal(query, list(exists = list(field = "individualId")))
})

test_that("field_missing creates correct query", {
  query <- field_missing("individualId")
  expect_true("bool" %in% names(query))
  expect_true("must_not" %in% names(query$bool))
})

cat("All query tests passed!\n")
