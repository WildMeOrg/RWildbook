\name{WildbookClient}
\alias{WildbookClient}
\title{WildbookClient R6 Class}
\description{
An R6 class for interacting with the Wildbook v3 API. Provides methods for
authentication, searching encounters and individuals, and managing sessions.
}
\details{
The WildbookClient handles session-based authentication using cookies and
provides a clean interface for querying Wildbook data.

Create a new client with \code{WildbookClient$new(base_url)}, then use
methods like \code{$login()}, \code{$search_encounters()}, and \code{$logout()}.
}
\examples{
\dontrun{
# Create a client
client <- WildbookClient$new(Sys.getenv("WILDBOOK_URL", "http://localhost:8080"))

# Login using environment variables
client$login()

# Or login with explicit credentials
client$login("user@example.com", "password")

# Search encounters
results <- client$search_encounters(match_all(), size = 10)

# Logout
client$logout()
}
}
\section{Methods}{
\describe{
\item{\code{new(base_url = NULL)}}{Create a new WildbookClient instance.
\code{base_url} can be provided directly or via WILDBOOK_URL environment variable.}

\item{\code{login(username = NULL, password = NULL)}}{Authenticate with the Wildbook API.
Credentials can be provided directly or via WILDBOOK_USERNAME and WILDBOOK_PASSWORD
environment variables.}

\item{\code{logout()}}{End the current session and log out.}

\item{\code{is_authenticated()}}{Check if currently authenticated.}

\item{\code{get_current_user()}}{Get information about the currently authenticated user.}

\item{\code{get_user_home()}}{Get dashboard data for the current user.}

\item{\code{search_encounters(query, from = 0, size = 10, sort = NULL, sort_order = NULL)}}{
Search for encounters using OpenSearch/Elasticsearch query syntax.}

\item{\code{get_encounter(encounter_id)}}{Get a specific encounter by UUID.}

\item{\code{search_individuals(query, from = 0, size = 10, sort = NULL, sort_order = NULL)}}{
Search for individuals using OpenSearch/Elasticsearch query syntax.}

\item{\code{get_individual(individual_id)}}{Get a specific individual by UUID.}

\item{\code{filter_current_user()}}{Create a query to filter encounters by the currently
authenticated user using the \code{assignedUsername} field.
Can be combined with other filters using \code{combine_queries()}.}
}
}
\seealso{
\code{\link{match_all}}, \code{\link{filter_by_species}}, \code{\link{combine_queries}}
}
