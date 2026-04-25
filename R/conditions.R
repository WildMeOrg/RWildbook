# Internal condition constructors for the Wildbook condition hierarchy.
# Not exported — users interact with these via tryCatch class matching only.
#
# All conditions inherit from "wildbook_error", which lets callers catch
# any Wildbook-originated error with a single handler:
#   tryCatch(..., wildbook_error = function(e) ...)
#
# Class hierarchy (outermost to innermost):
#   wildbook_{specific} -> wildbook_error -> error -> condition

.wildbook_condition <- function(message, class) {
  structure(
    class = c(class, "wildbook_error", "error", "condition"),
    list(message = message)
  )
}

wildbook_auth_error        <- function(msg) .wildbook_condition(msg, "wildbook_auth_error")
wildbook_not_authenticated <- function(msg) .wildbook_condition(msg, "wildbook_not_authenticated")
wildbook_forbidden         <- function(msg) .wildbook_condition(msg, "wildbook_forbidden")
wildbook_not_found         <- function(msg) .wildbook_condition(msg, "wildbook_not_found")
wildbook_bad_request       <- function(msg) .wildbook_condition(msg, "wildbook_bad_request")
wildbook_api_error         <- function(msg) .wildbook_condition(msg, "wildbook_api_error")
