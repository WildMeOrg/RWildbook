# Contributing to RWildbook

Thank you for your interest in contributing to RWildbook. This project is an R
client for the Wildbook v3 API and is maintained alongside the companion Python
client, pywildbook.

## Getting Help

Use the Wild Me community forum for questions, discussion, and support:

- https://community.wildme.org/

Use GitHub Issues for actionable bug reports, feature requests, and work that
should be tracked by maintainers:

- https://github.com/WildMeOrg/RWildbook/issues

## Before You Start

Before opening a pull request:

1. Check the issue tracker for related work.
2. Open an issue before starting a pull request.
3. Keep pull requests focused on one bug fix, feature, or documentation update.
4. Remember that RWildbook and pywildbook should remain feature-equivalent.

For changes that add or alter public functionality, please consider whether the
same behavior also needs to be added to pywildbook.

## Development Setup

This project uses R 4.2.0+, `httr2`, `R6`, `testthat`, `roxygen2`, and `lintr`.

```bash
git clone https://github.com/YOUR-USERNAME/RWildbook.git
cd RWildbook
git remote add upstream https://github.com/WildMeOrg/RWildbook.git
git fetch upstream
```

Contributions should come from a fork of the repository. Create a feature branch
in your fork for each issue you work on.

Install package dependencies from R:

```r
install.packages(c(
  "httr2",
  "R6",
  "testthat",
  "httptest2",
  "withr",
  "jsonlite",
  "roxygen2",
  "lintr",
  "devtools"
))
```

Install the local package for development:

```r
install.packages(".", repos = NULL, type = "source")
```

## Running Checks

Run the test suite:

```r
testthat::test_dir("tests/testthat")
```

Or with devtools:

```r
devtools::test()
```

Run linting:

```r
lintr::lint_package()
```

Run a package check before larger changes:

```bash
R CMD build .
R CMD check RWildbook_*.tar.gz
```

## Coding Conventions

Follow the existing project style:

- Use tidyverse style guide conventions for R code.
- Keep the public API small and consistent with the current `WildbookClient`
  R6 class and query helper patterns.
- Use typed conditions from `R/conditions.R` for Wildbook client and API errors.
- Require authentication for client methods that call protected API endpoints.
- Keep query helpers in `R/queries.R` and add tests for new helper behavior in
  `tests/testthat/test-queries.R`.
- Add or update roxygen2 comments for exported functions and methods.
- Regenerate documentation with `roxygen2::roxygenize()` after changing
  exported documentation.
- Mock HTTP behavior in unit tests. Do not require a running Wildbook server for
  ordinary unit tests.

## Testing Expectations

Every behavior change should include tests. In general:

- Add query helper tests in `tests/testthat/test-queries.R`.
- Add client behavior tests in `tests/testthat/test-client.R`.
- Prefer small, focused tests that do not depend on network access.
- Keep existing tests passing.

## Documentation

Update documentation when user-facing behavior changes. This may include:

- `README.md`
- Roxygen2 comments in `R/`
- Generated files in `man/`
- Vignettes in `vignettes/`
- Example scripts in `examples/`

If a new feature changes the public API, document the same expected behavior in
the companion pywildbook work when that parallel change is made.

## Pull Requests

Pull requests should be opened from your fork against the WildMeOrg RWildbook
repository.

When opening a pull request:

1. Explain what changed and why.
2. Link the related issue.
3. Include the checks you ran, such as `devtools::test()`,
   `lintr::lint_package()`, or `R CMD check`.
4. Mention any follow-up needed in pywildbook for feature parity.
5. Keep unrelated formatting or refactoring out of the pull request.

Maintainers may ask for changes before merging. Please keep discussion focused
on the specific issue or pull request.

## Security and Credentials

Do not commit credentials, access tokens, cookies, or local environment files.
Wildbook credentials should be supplied with environment variables:

- `WILDBOOK_URL`
- `WILDBOOK_USERNAME`
- `WILDBOOK_PASSWORD`

