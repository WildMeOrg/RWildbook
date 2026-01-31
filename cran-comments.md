# CRAN Submission Comments

## Package Information

**Package:** RWildbook
**Version:** 1.0.0
**Submission Type:** New version (complete rewrite)

## What's Changed

This is a complete rewrite of the RWildbook package. The previous version (0.9.3) interfaced with the legacy Wildbook framework using JDOQL queries. Version 1.0.0 is designed for the new Wildbook v3 REST API with a modern R6-based architecture.

### Breaking Changes

**Important:** This version is NOT backwards compatible with RWildbook < 1.0.0 due to the complete API redesign from legacy JDOQL interface to modern REST API.

The legacy code is preserved in the GitHub repository (branch: `archive/v0.9.3-legacy`) for users who need it.

### Justification for Rewrite

The Wildbook framework has evolved from a Java-based system with JDOQL queries to a modern REST API (v3). This necessitated a complete package rewrite to:

* Support the new API architecture
* Provide modern R programming patterns (R6 classes, native pipe)
* Improve usability with helper functions and better error handling
* Enable comprehensive testing with modern tools

## Test Environments

* Local: macOS 14.6, R 4.4.0
* GitHub Actions (planned):
  - Ubuntu 22.04 (release, devel, oldrel-1)
  - macOS-latest (release)
  - Windows-latest (release)
* win-builder: release, devel, oldrel-1 (to be tested before submission)
* R-hub: various platforms (to be tested before submission)

## R CMD check Results

```
0 errors ✓ | 0 warnings ✓ | 0 notes ✓
```

*(Note: Full check will be run before actual CRAN submission)*

## Downstream Dependencies

This package currently has no reverse dependencies.

## Additional Notes

### Examples and Tests

* All examples use `\dontrun{}` because they require:
  - A running Wildbook v3 instance
  - Valid authentication credentials
  - Internet connection
* Tests use httptest2 for mocking HTTP requests
* Tests gracefully skip when httptest2 is unavailable
* Package is designed for live API interaction (examples marked appropriately)

### External Services

This package is a client for the Wildbook v3 API:

* Wildbook is an open-source wildlife photo-identification platform
* Documentation: https://docs.wildme.org/
* Package requires user-provided Wildbook instance URL
* No embedded API keys or hardcoded credentials

### License

* MIT License (more permissive than previous GPL >= 2)
* Approved by Wild Me organization

### First Submission Expectations

As this is effectively a new package (complete rewrite), we expect:

* Possible questions about the breaking changes (documented in NEWS.md)
* Possible requests for clarification on API dependency
* All examples marked `\dontrun{}` due to authentication requirements (standard for API client packages)

We are committed to addressing any feedback promptly.

## Contact

Maintainer: Wild Me <dev@wildme.org>
GitHub: https://github.com/WildMeOrg/RWildbook
Issues: https://github.com/WildMeOrg/RWildbook/issues
