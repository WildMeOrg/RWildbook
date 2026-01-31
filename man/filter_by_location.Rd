\name{filter_by_location}
\alias{filter_by_location}
\title{Filter by Location}
\description{
Create a query to filter by location (country, location ID, or geographic bounding box)
}
\usage{
filter_by_location(country = NULL, location_id = NULL,
                   min_lat = NULL, max_lat = NULL,
                   min_lon = NULL, max_lon = NULL)
}
\arguments{
\item{country}{Country name (optional)}
\item{location_id}{Location ID (optional)}
\item{min_lat}{Minimum latitude for bounding box (optional)}
\item{max_lat}{Maximum latitude for bounding box (optional)}
\item{min_lon}{Minimum longitude for bounding box (optional)}
\item{max_lon}{Maximum longitude for bounding box (optional)}
}
\value{
A query list suitable for use with \code{WildbookClient$search_encounters()}.
}
\examples{
# Filter by country
query <- filter_by_location(country = "Kenya")

# Filter by bounding box
query <- filter_by_location(
  min_lat = -5.0, max_lat = 5.0,
  min_lon = 35.0, max_lon = 42.0
)
}
\seealso{
\code{\link{WildbookClient}}, \code{\link{filter_by_year_range}}, \code{\link{combine_queries}}
}
