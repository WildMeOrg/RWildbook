\name{filter_by_date_range}
\alias{filter_by_date_range}
\title{Filter by Date Range}
\description{
Create a query to filter by date range using the encounter \code{date} field.
Dates are formatted as ISO 8601 timestamps in UTC. The start date is
interpreted as the beginning of that day (\code{00:00:00Z}) and the end date
as the end of that day (\code{23:59:59Z}).
}
\usage{
filter_by_date_range(start_date = NULL, end_date = NULL)
}
\arguments{
\item{start_date}{Earliest date (inclusive). Accepts a \code{Date} object or
a string in \code{"YYYY-MM-DD"} format (optional).}
\item{end_date}{Latest date (inclusive). Accepts a \code{Date} object or
a string in \code{"YYYY-MM-DD"} format (optional).}
}
\value{
A query list suitable for use with \code{WildbookClient$search_encounters()}.
}
\examples{
# Encounters since 1 November 2025
query <- filter_by_date_range(start_date = "2025-11-01")

# Encounters between two dates
query <- filter_by_date_range(start_date = "2025-11-01", end_date = "2025-12-01")

# Using Date objects
query <- filter_by_date_range(start_date = as.Date("2025-11-01"))

\dontrun{
client <- WildbookClient$new("http://localhost:8080")
client$login()
results <- client$search_encounters(
  filter_by_date_range(start_date = "2025-01-01"),
  size = 10
)
}
}
\seealso{
\code{\link{WildbookClient}}, \code{\link{filter_by_year_range}}, \code{\link{combine_queries}}
}
