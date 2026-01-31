\name{combine_queries}
\alias{combine_queries}
\title{Combine Multiple Queries}
\description{
Combine multiple queries with boolean logic (AND, OR, NOT)
}
\usage{
combine_queries(..., operator = "must")
}
\arguments{
\item{...}{Query lists to combine}
\item{operator}{Boolean operator: "must" (AND), "should" (OR), or "must_not" (NOT)}
}
\value{
A combined query list suitable for use with \code{WildbookClient$search_encounters()}.
}
\examples{
# Combine multiple filters with AND
species <- filter_by_species("Megaptera", "novaeangliae")
sex <- filter_by_sex("female")
years <- filter_by_year_range(2020, 2023)
query <- combine_queries(species, sex, years, operator = "must")

# Combine with OR
query <- combine_queries(
  filter_by_sex("male"),
  filter_by_sex("female"),
  operator = "should"
)
}
\seealso{
\code{\link{WildbookClient}}, \code{\link{filter_by_species}}, \code{\link{match_all}}
}
