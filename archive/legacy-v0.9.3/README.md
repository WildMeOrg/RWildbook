# RWildbook v0.9.3 Legacy Archive

This directory contains the archived code from RWildbook v0.9.3, the legacy version that interfaced with the original Wildbook framework using JDOQL queries.

## Archive Information

- **Version:** 0.9.3
- **Archived Date:** 2026-01-30
- **Reason:** Complete rewrite for Wildbook v3 API (v1.0.0)
- **Archive Branch:** `archive/v0.9.3-legacy`
- **Archive Tag:** `v0.9.3-legacy`

## Contents

- `RWildbook/` - Legacy package source code
- `Testing/` - Test scripts
- `RWildbook_Design_Document.pdf` - Original design documentation
- `README-legacy.md` - Original README file

## Legacy Package Features

The legacy RWildbook package provided:
- JDOQL-based queries for Wildbook framework
- Functions: `searchWB()`, `WBjdoql()`, `markedData()`
- Integration with the `marked` package for mark-recapture analysis
- Two demo vignettes with sample data

## Installation (Historical)

To install the legacy version:

```bash
# Clone from archive branch
git clone -b archive/v0.9.3-legacy https://github.com/WildMeOrg/RWildbook.git
cd RWildbook

# Install in R
R CMD INSTALL RWildbook/
```

Or from this archive:

```r
# From the repository root
install.packages("archive/legacy-v0.9.3/RWildbook", repos = NULL, type = "source")
```

## Migration to v1.0.0

RWildbook v1.0.0+ uses a completely different architecture:
- R6 class-based interface (`WildbookClient`)
- REST API for Wildbook v3
- OpenSearch/Elasticsearch queries
- Modern dependencies (httr2, R6)

See the main README.md for current usage.

## Authors (Legacy)

- Simon Bonner (Author, Maintainer)
- Xinxin Huang (Author)

## License (Legacy)

GPL (>= 2)

---

**Note:** This code is archived for historical reference only. For current development, see the main repository and RWildbook v1.0.0+.
