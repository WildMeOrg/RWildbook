\name{filter_by_individual}
\alias{filter_by_individual}
\title{Filter by Individual}
\description{
Create a query to find encounters for a specific individual
}
\usage{
filter_by_individual(individual_id)
}
\arguments{
\item{individual_id}{Individual UUID}
}
\value{
A query list suitable for use with \code{WildbookClient$search_encounters()}.
}
\examples{
query <- filter_by_individual("550e8400-e29b-41d4-a716-446655440000")
}
\seealso{
\code{\link{WildbookClient}}, \code{\link{filter_by_submitter}}
}
