# RWildbook 1.0.0

## Major Changes

This is a complete rewrite of the RWildbook package to support the Wildbook v3 API. The package is not backwards compatible with RWildbook < 1.0.0.

### New Architecture

* Complete rewrite for Wildbook v3 REST API (not compatible with legacy Wildbook)
* R6 class-based interface via `WildbookClient`
* Session-based authentication with automatic cookie management
* Modern HTTP handling with httr2
* OpenSearch/Elasticsearch query support

### Breaking Changes

* **Not compatible with RWildbook v0.9.x** - Legacy JDOQL-based interface removed
* **Requires Wildbook v3 API** - Will not work with older Wildbook versions
* **Minimum R version now 4.0.0** - Required for native pipe operator support
* Complete API redesign - All functions from v0.9.x have been replaced

### New Features

* `WildbookClient` R6 class for clean object-oriented API interaction
* Query helper functions: `match_all()`, `filter_by_*()`, `combine_queries()`
* Support for searching encounters and individuals
* Environment variable support for credentials (WILDBOOK_URL, WILDBOOK_USERNAME, WILDBOOK_PASSWORD)
* Comprehensive error handling and informative messages
* Automatic session management with cookie handling

### Documentation

* Comprehensive README with examples
* Full roxygen2 documentation for all exported functions
* 78 unit tests with 100% pass rate using testthat 3.x
* httptest2 integration for mocking HTTP requests in tests

### Dependencies

* New dependencies: httr2, R6
* Retained: jsonlite
* Removed: data.table, utils (base R functions), marked

## Legacy Code

The legacy RWildbook v0.9.3 code (JDOQL-based) is preserved in the GitHub repository:

* Branch: `archive/v0.9.3-legacy`
* Tag: `v0.9.3-legacy`
* Archive directory: `archive/legacy-v0.9.3/`

Users requiring the legacy interface can install from the archive branch.

## Authors

* Wild Me (Maintainer, Author)
* Simon Bonner (Contributor - original package author)
* Xinxin Huang (Contributor - original package author)

## Acknowledgments

This rewrite builds on the foundational work of Simon Bonner and Xinxin Huang, who created the original RWildbook package for the legacy Wildbook framework.
