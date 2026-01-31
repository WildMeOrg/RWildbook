\name{field_exists}
\alias{field_exists}
\title{Field Exists Query}
\description{
Create a query to find documents where a field exists (has a value)
}
\usage{
field_exists(field)
}
\arguments{
\item{field}{Field name}
}
\value{
A query list suitable for use with \code{WildbookClient$search_encounters()}.
}
\examples{
# Find individuals with encounters
query <- field_exists("encounters")

# Find encounters with assigned individuals
query <- field_exists("individualId")
}
\seealso{
\code{\link{field_missing}}, \code{\link{text_search}}, \code{\link{WildbookClient}}
}
