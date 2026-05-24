#' Panneau de navigation pour page_sidebarHL
#'
#' Définit une page du dashboard. Chaque `hl_nav_panel()` crée un bouton dans
#' la sidebar et une zone de contenu correspondante.
#'
#' @param title Label affiché dans la sidebar et utilisé comme titre de page.
#' @param ... Contenu de la page (tags Shiny/HTML).
#' @param icon Icône optionnelle. Utiliser [shiny::icon()] ou [bsicons::bs_icon()].
#' @param value Identifiant interne pour le routing. Doit être unique. Par
#'   défaut égal à `title`.
#'
#' @return Un objet de classe `"hl_nav_panel"`, à passer à [page_sidebarHL()]
#'   directement ou dans un [hl_nav_group()].
#'
#' @export
hl_nav_panel <- function(title, ..., icon = NULL, value = title) {
  structure(
    list(
      title   = title,
      value   = value,
      icon    = icon,
      content = list(...)
    ),
    class = "hl_nav_panel"
  )
}
