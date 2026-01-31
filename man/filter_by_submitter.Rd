\name{filter_by_submitter}
\alias{filter_by_submitter}
\title{Filter by Submitter}
\description{
Create a query to filter by submitter (user who submitted the encounter)
}
\usage{
filter_by_submitter(submitter_id)
}
\arguments{
\item{submitter_id}{Submitter user ID or UUID}
}
\value{
A query list suitable for use with \code{WildbookClient$search_encounters()}.
}
\examples{
query <- filter_by_submitter("user@example.com")
}
\seealso{
\code{\link{WildbookClient}}, \code{\link{filter_by_individual}}
}
