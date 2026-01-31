\name{match_all}
\alias{match_all}
\title{Match All Query}
\description{
Create a query that matches all documents
}
\usage{
match_all()
}
\value{
A query list suitable for use with \code{WildbookClient$search_encounters()}
or \code{WildbookClient$search_individuals()}.
}
\examples{
query <- match_all()

\dontrun{
client <- WildbookClient$new("http://localhost:8080")
client$login()
results <- client$search_encounters(match_all(), size = 10)
}
}
\seealso{
\code{\link{WildbookClient}}, \code{\link{filter_by_species}}, \code{\link{combine_queries}}
}
