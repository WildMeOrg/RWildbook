\name{filter_by_species}
\alias{filter_by_species}
\title{Filter by Species}
\description{
Create a query to filter by species (genus and specific epithet)
}
\usage{
filter_by_species(genus, specific_epithet = NULL)
}
\arguments{
\item{genus}{Genus name}
\item{specific_epithet}{Specific epithet (optional)}
}
\value{
A query list suitable for use with \code{WildbookClient$search_encounters()}.
}
\examples{
# Filter by genus and species
query <- filter_by_species("Megaptera", "novaeangliae")

# Filter by genus only
query <- filter_by_species("Megaptera")

\dontrun{
client <- WildbookClient$new("http://localhost:8080")
client$login()
results <- client$search_encounters(
  filter_by_species("Tursiops", "truncatus"),
  size = 10
)
}
}
\seealso{
\code{\link{WildbookClient}}, \code{\link{filter_by_sex}}, \code{\link{combine_queries}}
}
