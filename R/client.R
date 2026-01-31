# API Endpoint Constants
API_LOGIN <- '/api/v3/login'
API_LOGOUT <- '/api/v3/logout'
API_USER <- '/api/v3/user'
API_HOME <- '/api/v3/home'
API_SEARCH_ENCOUNTER <- '/api/v3/search/encounter'
API_ENCOUNTERS_BASE <- '/api/v3/encounters/'
API_SEARCH_INDIVIDUAL <- '/api/v3/search/individual'
API_INDIVIDUALS_BASE <- '/api/v3/individuals/'

#' WildbookClient R6 Class
#'
#' @description
#' An R6 class for interacting with the Wildbook v3 API. Provides methods for
#' authentication, searching encounters and individuals, and managing sessions.
#'
#' @details
#' The WildbookClient handles session-based authentication using cookies and
#' provides a clean interface for querying Wildbook data.
#'
#' @import R6
#' @import httr2
#' @import jsonlite
#'
#' @export
#' @examples
#' \dontrun{
#' # Create a client
#' client <- WildbookClient$new(Sys.getenv("WILDBOOK_URL", "http://localhost:8080"))
#'
#' # Login using environment variables
#' client$login()
#'
#' # Or login with explicit credentials
#' client$login("user@example.com", "password")
#'
#' # Search encounters
#' results <- client$search_encounters(match_all(), size = 10)
#'
#' # Logout
#' client$logout()
#' }
WildbookClient <- R6::R6Class(
  "WildbookClient",

  public = list(
    #' @field base_url The base URL of the Wildbook instance
    base_url = NULL,

    #' @description
    #' Create a new WildbookClient instance
    #' @param base_url Base URL of the Wildbook instance (e.g., "http://localhost:8080").
    #'   Can also be set via WILDBOOK_URL environment variable.
    #' @return A new WildbookClient object
    initialize = function(base_url = NULL) {
      if (is.null(base_url)) {
        base_url <- Sys.getenv("WILDBOOK_URL")
        if (base_url == "") {
          stop("base_url not provided and WILDBOOK_URL environment variable not set", call. = FALSE)
        }
      }
      self$base_url <- sub("/$", "", base_url)
      private$authenticated <- FALSE
      private$session_cookies <- NULL
      private$user_info <- NULL
    },

    #' @description
    #' Authenticate with the Wildbook API
    #' @param username Username or email address. If not provided, attempts to read from
    #'   WILDBOOK_USERNAME environment variable.
    #' @param password User password. If not provided, attempts to read from
    #'   WILDBOOK_PASSWORD environment variable.
    #' @return User information list
    login = function(username = NULL, password = NULL) {
      # Get credentials from environment if not provided
      if (is.null(username)) {
        username <- Sys.getenv("WILDBOOK_USERNAME")
        if (username == "") {
          stop("username not provided and WILDBOOK_USERNAME environment variable not set", call. = FALSE)
        }
      }
      if (is.null(password)) {
        password <- Sys.getenv("WILDBOOK_PASSWORD")
        if (password == "") {
          stop("password not provided and WILDBOOK_PASSWORD environment variable not set", call. = FALSE)
        }
      }

      url <- private$make_url(API_LOGIN)

      req <- httr2::request(url) |>
        httr2::req_method("POST") |>
        httr2::req_body_json(list(
          username = username,
          password = password
        ))

      resp <- tryCatch(
        httr2::req_perform(req),
        error = function(e) {
          stop("Login request failed: ", e$message, call. = FALSE)
        }
      )

      data <- private$handle_response(resp)

      if (isTRUE(data$success)) {
        private$authenticated <- TRUE
        private$user_info <- data
        # Extract cookies from response
        private$session_cookies <- resp$headers$`set-cookie`

        message("Logged in successfully as: ", data$username)
        invisible(data)
      } else {
        stop("Login failed: ", data$error %||% "Unknown error", call. = FALSE)
      }
    },

    #' @description
    #' End the current session and log out
    #' @return TRUE if logout was successful
    logout = function() {
      url <- private$make_url(API_LOGOUT)

      req <- httr2::request(url) |>
        httr2::req_method("POST")

      if (!is.null(private$session_cookies)) {
        req <- httr2::req_headers(req, Cookie = private$session_cookies)
      }

      tryCatch({
        resp <- httr2::req_perform(req)
        data <- private$handle_response(resp)
        private$authenticated <- FALSE
        private$user_info <- NULL
        private$session_cookies <- NULL
        message("Logged out successfully")
        invisible(TRUE)
      }, error = function(e) {
        # Clear session even on error
        private$authenticated <- FALSE
        private$user_info <- NULL
        private$session_cookies <- NULL
        warning("Logout request failed but session cleared: ", e$message)
        invisible(FALSE)
      })
    },

    #' @description
    #' Check if currently authenticated
    #' @return TRUE if authenticated, FALSE otherwise
    is_authenticated = function() {
      private$authenticated
    },

    #' @description
    #' Get information about the currently authenticated user
    #' @return User information list
    get_current_user = function() {
      private$check_auth()

      url <- private$make_url(API_USER)
      req <- private$make_authenticated_request(url)

      resp <- httr2::req_perform(req)
      private$handle_response(resp)
    },

    #' @description
    #' Get dashboard data for the current user
    #' @return Dashboard data list including recent encounters, projects, etc.
    get_user_home = function() {
      private$check_auth()

      url <- private$make_url(API_HOME)
      req <- private$make_authenticated_request(url)

      resp <- httr2::req_perform(req)
      private$handle_response(resp)
    },

    #' @description
    #' Search for encounters using OpenSearch/Elasticsearch query syntax
    #' @param query Query list (e.g., list(match_all = list()))
    #' @param from Pagination offset (default: 0)
    #' @param size Number of results to return (default: 10)
    #' @param sort Field to sort by (optional)
    #' @param sort_order Sort order "asc" or "desc" (optional)
    #' @return Search results list with hits and metadata
    search_encounters = function(query, from = 0, size = 10, sort = NULL, sort_order = NULL) {
      private$check_auth()

      url <- private$make_url(API_SEARCH_ENCOUNTER)

      # Wrap query in "query" key if not already wrapped
      if (!("query" %in% names(query))) {
        search_body <- list(query = query)
      } else {
        search_body <- query
      }

      req <- private$make_authenticated_request(url) |>
        httr2::req_method("POST") |>
        httr2::req_body_json(search_body)

      # Add query parameters
      params <- list(from = from, size = size)
      if (!is.null(sort)) params$sort <- sort
      if (!is.null(sort_order)) params$sortOrder <- sort_order

      req <- httr2::req_url_query(req, !!!params)

      resp <- httr2::req_perform(req)
      private$handle_response(resp)
    },

    #' @description
    #' Get details of a specific encounter by UUID
    #' @param encounter_id Encounter UUID
    #' @return Encounter details list
    get_encounter = function(encounter_id) {
      private$check_auth()

      url <- private$make_url(paste0(API_ENCOUNTERS_BASE, encounter_id))
      req <- private$make_authenticated_request(url)

      resp <- httr2::req_perform(req)
      private$handle_response(resp)
    },

    #' @description
    #' Search for individuals using OpenSearch/Elasticsearch query syntax
    #' @param query Query list
    #' @param from Pagination offset (default: 0)
    #' @param size Number of results to return (default: 10)
    #' @param sort Field to sort by (optional)
    #' @param sort_order Sort order "asc" or "desc" (optional)
    #' @return Search results list with hits and metadata
    search_individuals = function(query, from = 0, size = 10, sort = NULL, sort_order = NULL) {
      private$check_auth()

      url <- private$make_url(API_SEARCH_INDIVIDUAL)

      # Wrap query in "query" key if not already wrapped
      if (!("query" %in% names(query))) {
        search_body <- list(query = query)
      } else {
        search_body <- query
      }

      req <- private$make_authenticated_request(url) |>
        httr2::req_method("POST") |>
        httr2::req_body_json(search_body)

      # Add query parameters
      params <- list(from = from, size = size)
      if (!is.null(sort)) params$sort <- sort
      if (!is.null(sort_order)) params$sortOrder <- sort_order

      req <- httr2::req_url_query(req, !!!params)

      resp <- httr2::req_perform(req)
      private$handle_response(resp)
    },

    #' @description
    #' Get details of a specific individual by UUID
    #' @param individual_id Individual UUID
    #' @return Individual details list
    get_individual = function(individual_id) {
      private$check_auth()

      url <- private$make_url(paste0(API_INDIVIDUALS_BASE, individual_id))
      req <- private$make_authenticated_request(url)

      resp <- httr2::req_perform(req)
      private$handle_response(resp)
    },

    #' @description
    #' Create a query to filter encounters by the currently authenticated user.
    #' Uses the \code{assignedUsername} field to match encounters associated with
    #' the logged-in user. The returned query can be combined with other filters
    #' using \code{combine_queries()}.
    #' @return A query list filtering by the current user's username
    filter_current_user = function() {
      private$check_auth()
      list(
        bool = list(
          filter = list(
            list(terms = list(assignedUsername = list(private$user_info$username)))
          )
        )
      )
    }
  ),

  private = list(
    authenticated = FALSE,
    session_cookies = NULL,
    user_info = NULL,

    # Construct full URL from path
    make_url = function(path) {
      path <- sub("^/", "", path)
      paste0(self$base_url, "/", path)
    },

    # Create authenticated request with session cookie
    make_authenticated_request = function(url) {
      req <- httr2::request(url)

      if (!is.null(private$session_cookies)) {
        req <- httr2::req_headers(req, Cookie = private$session_cookies)
      }

      req
    },

    # Check if authenticated, throw error if not
    check_auth = function() {
      if (!private$authenticated) {
        stop("Not authenticated. Call login() first.", call. = FALSE)
      }
    },

    # Handle API response and raise appropriate errors
    handle_response = function(resp) {
      status <- httr2::resp_status(resp)

      # Try to parse JSON response
      data <- tryCatch(
        httr2::resp_body_json(resp),
        error = function(e) list()
      )

      if (status == 200) {
        return(data)
      } else if (status == 401) {
        error_msg <- data$error %||% "Authentication failed"
        stop("Authentication error: ", error_msg, call. = FALSE)
      } else if (status == 403) {
        stop("Access forbidden", call. = FALSE)
      } else if (status == 404) {
        stop("Resource not found", call. = FALSE)
      } else if (status == 400) {
        errors <- data$errors
        if (!is.null(errors) && length(errors) > 0) {
          error_msgs <- sapply(errors, function(e) e$message %||% "")
          error_msg <- paste(error_msgs, collapse = ", ")
        } else {
          error_msg <- "Bad request"
        }
        stop("Bad request: ", error_msg, call. = FALSE)
      } else {
        error_msg <- data$error %||% paste("HTTP", status)
        stop("API error: ", error_msg, call. = FALSE)
      }
    }
  )
)

# Helper operator for NULL coalescing
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
