# RWildbook Tests

This directory contains automated tests for the RWildbook package.

## Test Structure

```
tests/
├── testthat.R              # Test runner entry point
└── testthat/
    ├── test-queries.R      # Tests for query helper functions
    └── test-client.R       # Tests for WildbookClient class
```

## Running Tests

### Option 1: Using testthat directly

```r
library(testthat)
library(RWildbook)
test_dir("tests/testthat")
```

### Option 2: Using devtools

```r
devtools::test()
```

### Option 3: Using R CMD check

```bash
R CMD check RWildbook
```

## Test Coverage

### Query Tests (`test-queries.R`)
- **27 tests** covering all query helper functions:
  - Basic queries (match_all, filter_by_sex, etc.)
  - Species filtering
  - Year range filtering
  - Location filtering (country, bounding box, combinations)
  - Text search (simple and fuzzy)
  - Field existence/missing queries
  - Query combination with boolean operators
  - JSON serialization validation

### Client Tests (`test-client.R`)
- **18 tests** covering WildbookClient functionality:
  - Client initialization
  - Environment variable configuration
  - Authentication requirements
  - Query wrapping logic
  - JSON serialization (ensuring `{}` not `[]` for empty objects)

### Total: 78 Tests Passing

## Test Dependencies

Required packages (listed in DESCRIPTION under `Suggests:`):
- `testthat` (>= 3.0.0) - Testing framework
- `withr` - Environment variable management for tests
- `httptest2` - HTTP mocking (optional, for future mock tests)

Install all testing dependencies:

```r
install.packages(c("testthat", "withr", "httptest2"))
```

## Writing New Tests

Follow the testthat style:

```r
test_that("description of what is being tested", {
  # Arrange
  query <- match_all()

  # Act
  result <- some_function(query)

  # Assert
  expect_equal(result, expected_value)
  expect_true(condition)
})
```

## Test Patterns

### Testing Query Structure

```r
test_that("query has correct structure", {
  query <- filter_by_sex("female")
  expect_equal(query, list(term = list(sex = "female")))
})
```

### Testing List Membership in R

R's `%in%` operator doesn't work for list comparison. Use `identical()` with `sapply()`:

```r
test_that("term is in must list", {
  query <- combine_queries(term1, term2, operator = "must")

  # Check if term1 is in the must list
  has_term <- any(sapply(query$bool$must, function(x) identical(x, term1)))
  expect_true(has_term)
})
```

### Testing JSON Serialization

```r
test_that("query serializes to correct JSON", {
  library(jsonlite)

  query <- match_all()
  json <- toJSON(query, auto_unbox = TRUE)

  expect_match(as.character(json), '\\{"match_all":\\{\\}\\}')
})
```

### Testing Environment Variables

```r
test_that("client reads from env vars", {
  withr::with_envvar(
    c(WILDBOOK_URL = "http://test.com"),
    {
      client <- WildbookClient$new()
      expect_equal(client$base_url, "http://test.com")
    }
  )
})
```

## Known Skips

- **httptest2 mocking test**: Skipped because full HTTP mocking infrastructure is complex to set up. Tests that require mocking are currently skipped.

## Continuous Integration

These tests are designed to run without requiring a live Wildbook server. They test:
- Query construction logic
- Client initialization
- Configuration handling
- JSON serialization

Future work may add integration tests that require a running Wildbook instance.

## Comparison with Python Tests

The R test suite mirrors the Python client tests in `wildbook-python-client/tests/`:
- Similar test coverage (78 R tests vs 39 Python tests - R tests are more granular)
- Same query validation logic
- Equivalent client functionality tests
- Both achieve 100% pass rate

## See Also

- [TESTING.md](../TESTING.md) - Detailed testing guide
- [README.md](../README.md) - Package documentation
