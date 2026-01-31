\name{filter_by_year_range}
\alias{filter_by_year_range}
\title{Filter by Year Range}
\description{
Create a query to filter by year range
}
\usage{
filter_by_year_range(start_year = NULL, end_year = NULL)
}
\arguments{
\item{start_year}{Start year (inclusive, optional)}
\item{end_year}{End year (inclusive, optional)}
}
\value{
A query list suitable for use with \code{WildbookClient$search_encounters()}.
}
\examples{
# Encounters from 2020 to 2023
query <- filter_by_year_range(2020, 2023)

# Encounters from 2020 onwards
query <- filter_by_year_range(start_year = 2020)

# Encounters up to 2022
query <- filter_by_year_range(end_year = 2022)
}
\seealso{
\code{\link{WildbookClient}}, \code{\link{filter_by_location}}, \code{\link{combine_queries}}
}
