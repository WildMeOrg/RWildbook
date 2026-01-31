\name{filter_by_sex}
\alias{filter_by_sex}
\title{Filter by Sex}
\description{
Create a query to filter by sex
}
\usage{
filter_by_sex(sex)
}
\arguments{
\item{sex}{Sex value (e.g., "male", "female", "unknown")}
}
\value{
A query list suitable for use with \code{WildbookClient$search_encounters()}.
}
\examples{
query <- filter_by_sex("female")

\dontrun{
client <- WildbookClient$new("http://localhost:8080")
client$login()
results <- client$search_encounters(filter_by_sex("male"), size = 10)
}
}
\seealso{
\code{\link{WildbookClient}}, \code{\link{filter_by_species}}, \code{\link{combine_queries}}
}
