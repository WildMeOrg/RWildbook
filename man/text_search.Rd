\name{text_search}
\alias{text_search}
\title{Text Search}
\description{
Create a query to search for text in a specific field
}
\usage{
text_search(field, text, fuzzy = FALSE)
}
\arguments{
\item{field}{Field name to search in}
\item{text}{Text to search for}
\item{fuzzy}{Use fuzzy matching (default: FALSE)}
}
\value{
A query list suitable for use with \code{WildbookClient$search_encounters()}.
}
\examples{
# Search for "beach" in locality descriptions
query <- text_search("verbatimLocality", "beach", fuzzy = TRUE)

# Exact match search
query <- text_search("submitterName", "John Doe")
}
\seealso{
\code{\link{WildbookClient}}, \code{\link{field_exists}}, \code{\link{field_missing}}
}
