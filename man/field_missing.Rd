\name{field_missing}
\alias{field_missing}
\title{Field Missing Query}
\description{
Create a query to find documents where a field is missing (has no value)
}
\usage{
field_missing(field)
}
\arguments{
\item{field}{Field name}
}
\value{
A query list suitable for use with \code{WildbookClient$search_encounters()}.
}
\examples{
# Find encounters without an assigned individual
query <- field_missing("individualId")

# Find encounters without sex information
query <- field_missing("sex")
}
\seealso{
\code{\link{field_exists}}, \code{\link{text_search}}, \code{\link{WildbookClient}}
}
