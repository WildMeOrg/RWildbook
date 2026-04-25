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
      private$cookie_path <- tempfile(pattern = "wildbook_cookies_")
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
        )) |>
        httr2::req_cookie_preserve(private$cookie_path)

      resp <- private$safe_perform(req)

      data <- private$handle_response(resp)

      if (isTRUE(data$success)) {
        private$authenticated <- TRUE
        private$user_info <- data

        message("Logged in successfully as: ", data$username)
        invisible(data)
      } else {
        stop(wildbook_auth_error(paste0("Login failed: ", data$error %||% "Unknown error")))
      }
    },

    #' @description
    #' End the current session and log out
    #' @return TRUE if logout was successful
    logout = function() {
      url <- private$make_url(API_LOGOUT)

      req <- httr2::request(url) |>
        httr2::req_method("POST") |>
        httr2::req_cookie_preserve(private$cookie_path)

      tryCatch({
        resp <- private$safe_perform(req)
        data <- private$handle_response(resp)
        private$authenticated <- FALSE
        private$user_info <- NULL
        if (file.exists(private$cookie_path)) file.remove(private$cookie_path)
        message("Logged out successfully")
        invisible(TRUE)
      }, error = function(e) {
        # Clear session even on error
        private$authenticated <- FALSE
        private$user_info <- NULL
        if (file.exists(private$cookie_path)) file.remove(private$cookie_path)
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

      resp <- private$safe_perform(req)
      private$handle_response(resp)
    },

    #' @description
    #' Get dashboard data for the current user
    #' @return Dashboard data list including recent encounters, projects, etc.
    get_user_home = function() {
      private$check_auth()

      url <- private$make_url(API_HOME)
      req <- private$make_authenticated_request(url)

      resp <- private$safe_perform(req)
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
      private$search_resource(API_SEARCH_ENCOUNTER, query, from, size, sort, sort_order)
    },

    #' @description
    #' Get details of a specific encounter by UUID
    #' @param encounter_id Encounter UUID
    #' @return Encounter details list
    get_encounter = function(encounter_id) {
      private$check_auth()

      url <- private$make_url(paste0(API_ENCOUNTERS_BASE, encounter_id))
      req <- private$make_authenticated_request(url)

      resp <- private$safe_perform(req)
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
      private$search_resource(API_SEARCH_INDIVIDUAL, query, from, size, sort, sort_order)
    },

    #' @description
    #' Get details of a specific individual by UUID
    #' @param individual_id Individual UUID
    #' @return Individual details list
    get_individual = function(individual_id) {
      private$check_auth()

      url <- private$make_url(paste0(API_INDIVIDUALS_BASE, individual_id))
      req <- private$make_authenticated_request(url)

      resp <- private$safe_perform(req)
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
    cookie_path = NULL,
    user_info = NULL,

    # Construct full URL from path
    make_url = function(path) {
      path <- sub("^/", "", path)
      paste0(self$base_url, "/", path)
    },

    # Create authenticated request with session cookie
    make_authenticated_request = function(url) {
      httr2::request(url) |>
        httr2::req_cookie_preserve(private$cookie_path)
    },

    # Check if authenticated, throw error if not
    check_auth = function() {
      if (!private$authenticated) {
        stop(wildbook_not_authenticated("Not authenticated. Call login() first."))
      }
    },

    # Suppress httr2's automatic error-on-4xx/5xx so handle_response()
    # can classify errors with package-specific messages.
    safe_perform = function(req) {
      httr2::req_error(req, is_error = function(resp) FALSE) |>
        httr2::req_perform()
    },

    # Shared logic for search_encounters and search_individuals.
    search_resource = function(endpoint, query, from, size, sort, sort_order) {
      url <- private$make_url(endpoint)

      if (!("query" %in% names(query))) {
        search_body <- list(query = query)
      } else {
        search_body <- query
      }

      if (!is.null(sort_order)) {
        sort_order <- match.arg(sort_order, c("asc", "desc"))
      }

      req <- private$make_authenticated_request(url) |>
        httr2::req_method("POST") |>
        httr2::req_body_json(search_body)

      params <- list(from = from, size = size)
      if (!is.null(sort)) params$sort <- sort
      if (!is.null(sort_order)) params$sortOrder <- sort_order

      req <- do.call(httr2::req_url_query, c(list(req), params))

      resp <- private$safe_perform(req)
      private$handle_response(resp)
    },

    # Handle API response and raise appropriate errors
    handle_response = function(resp) {
      status <- httr2::resp_status(resp)

      data <- tryCatch(
        httr2::resp_body_json(resp),
        error = function(e) list()
      )

      if (status == 200) {
        return(data)
      } else if (status == 401) {
        error_msg <- data$error %||% "Authentication failed"
        stop(wildbook_auth_error(paste0("Authentication error: ", error_msg)))
      } else if (status == 403) {
        stop(wildbook_forbidden("Access forbidden"))
      } else if (status == 404) {
        stop(wildbook_not_found("Resource not found"))
      } else if (status == 400) {
        errors <- data$errors
        if (!is.null(errors) && length(errors) > 0) {
          error_msgs <- sapply(errors, function(e) e$message %||% "")
          error_msg <- paste(error_msgs, collapse = ", ")
        } else {
          error_msg <- "Bad request"
        }
        stop(wildbook_bad_request(paste0("Bad request: ", error_msg)))
      } else {
        error_msg <- data$error %||% paste("HTTP", status)
        stop(wildbook_api_error(paste0("API error: ", error_msg)))
      }
    }
  )
)

# Helper operator for NULL coalescing
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
