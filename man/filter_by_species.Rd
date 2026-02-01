\name{filter_by_species}
\alias{filter_by_species}
\title{Filter by Species}
\description{
Create a query to filter by species. Searches across the \code{taxonomy},
\code{genus}, and \code{specificEpithet} fields simultaneously, since not all
encounters populate the same fields. When only a species name is provided,
matches either the \code{taxonomy} field ending with that species or the
\code{specificEpithet} field directly. When genus is also provided (or a
full \code{"Genus species"} string is passed), matches either the combined
\code{taxonomy} field or both \code{genus} and \code{specificEpithet}
individually.
}
\usage{
filter_by_species(species, genus = NULL)
}
\arguments{
\item{species}{Species (specific epithet), or a full species name as a
single string (e.g., \code{"Equus grevyi"}) which will be automatically
split into genus and species.}
\item{genus}{Genus name (optional). When provided, the query matches on
both genus and species fields.}
}
\value{
A query list suitable for use with \code{WildbookClient$search_encounters()}.
}
\examples{
# Filter by species only
query <- filter_by_species("novaeangliae")

# Filter by genus and species as a single string
query <- filter_by_species("Megaptera novaeangliae")

# Filter by genus and species using both parameters
query <- filter_by_species("novaeangliae", genus = "Megaptera")

\dontrun{
client <- WildbookClient$new("http://localhost:8080")
client$login()
results <- client$search_encounters(
  filter_by_species("Megaptera novaeangliae"),
  size = 10
)
}
}
\seealso{
\code{\link{WildbookClient}}, \code{\link{filter_by_sex}}, \code{\link{combine_queries}}
}
