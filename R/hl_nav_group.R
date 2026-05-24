#' Groupe de navigation collapsible pour page_sidebarHL
#'
#' Regroupe plusieurs [hl_nav_panel()] sous une section repliable dans la
#' sidebar.
#'
#' @param title Label affiché dans la sidebar pour l'en-tête du groupe.
#' @param ... Objets [hl_nav_panel()].
#' @param icon Icône optionnelle. Utiliser [shiny::icon()] ou [bsicons::bs_icon()].
#' @param expanded Logique. Si `TRUE`, le groupe démarre déplié. Défaut `FALSE`.
#'
#' @return Un objet de classe `"hl_nav_group"`, à passer à [page_sidebarHL()].
#'
#' @export
hl_nav_group <- function(title, ..., icon = NULL, expanded = FALSE) {
  children <- list(...)
  is_panel <- vapply(children, inherits, logical(1), "hl_nav_panel")
  if (!all(is_panel)) {
    stop(
      "Tous les enfants de hl_nav_group() doivent \u00eatre des hl_nav_panel().",
      call. = FALSE
    )
  }
  structure(
    list(
      title    = title,
      icon     = icon,
      expanded = expanded,
      children = children
    ),
    class = "hl_nav_group"
  )
}
