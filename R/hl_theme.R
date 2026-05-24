#' Theme bslib standard de bslibHL
#'
#' Cree un [bslib::bs_theme()] pre-configure avec le look par defaut de
#' bslibHL. Sert de point de depart — tous les parametres de [bslib::bs_theme()]
#' peuvent etre passes via `...` pour personnaliser davantage.
#'
#' @param primary Couleur primaire (boutons sidebar, liens actifs, etc.).
#'   Defaut : `"#3c8dbc"`.
#' @param bootswatch Theme Bootswatch de base. Defaut : `"darkly"`.
#' @param ... Arguments supplementaires passes a [bslib::bs_theme()]
#'   (ex. `base_font`, `secondary`, etc.).
#'
#' @return Un objet `bs_theme` utilisable dans le parametre `theme` de
#'   [page_sidebarHL()] ou de n'importe quelle page bslib.
#'
#' @examples
#' \dontrun{
#' # Look standard
#' page_sidebarHL(theme = hl_theme(), ...)
#'
#' # Variante avec une autre couleur primaire
#' page_sidebarHL(theme = hl_theme(primary = "#27ae60"), ...)
#'
#' # Autre bootswatch
#' page_sidebarHL(theme = hl_theme(bootswatch = "flatly", primary = "#2c3e50"), ...)
#' }
#'
#' @export
hl_theme <- function(primary = "#3c8dbc", bootswatch = "darkly", ...) {
  bslib::bs_theme(
    bootswatch = bootswatch,
    primary    = primary,
    ...
  )
}
