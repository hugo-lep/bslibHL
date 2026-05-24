#' Dashboard sidebar multi-page base sur bslib
#'
#' Layout de dashboard combinant une sidebar de navigation persistante et un
#' contenu multi-page. Etend [bslib::page_sidebar()] avec navigation groupee,
#' badges animes dans le header et panneaux dropdown.
#'
#' Appeler [page_sidebarHL_server()] dans le `server` pour activer le routing
#' et le suivi d'URL.
#'
#' @param ... [hl_nav_panel()] et/ou [hl_nav_group()] definissant les pages,
#'   plus des elements HTML optionnels (ex. panneaux dropdown de protegR2).
#' @param title Titre affiche dans la barre de header. Chaine de caracteres ou
#'   tag HTML. Pour ajouter des elements a droite (boutons, badges), passer un
#'   tag construit manuellement (ex. `htmltools::tags$div(...)`) et les
#'   classes CSS `hl-header-wrapper` / `hl-header-title` / `hl-header-items`.
#' @param theme Objet [bslib::bs_theme()].
#' @param sidebar_width Largeur de la sidebar en pixels. Defaut `250`.
#' @param selected Valeur du [hl_nav_panel()] affiche au demarrage. Par defaut
#'   le premier panneau. Pour restaurer l'onglet actif depuis l'URL (avec
#'   protegR2), passer :
#'   `selected = isolate(shiny::getQueryString(session))$page`
#' @param sidebar_open Etat initial de la sidebar. Voir [bslib::sidebar()].
#'   Defaut `"always"`.
#' @param window_title Titre de l'onglet navigateur. Par defaut egal a `title`.
#' @param protegR2_compat Logique. Si `TRUE`, masque les boutons fixes de
#'   protegR2 (`.protegr2-logout-fixed`, `.protegr2-idioma-fixed`) qui
#'   entreraient en conflit avec le header bslibHL. Defaut `FALSE`.
#' @param nav_bg Couleur de fond des boutons principaux de la sidebar (chaine
#'   CSS valide, ex. `"#e74c3c"` ou `"rgb(231,76,60)"`). `NULL` = suit
#'   automatiquement `primary` du theme [bslib::bs_theme()].
#' @param nav_sub_bg Couleur de fond des sous-items dans un [hl_nav_group()].
#'   `NULL` = valeur par defaut `#1e282c`.
#'
#' @section Personnalisation des couleurs:
#'
#' Les couleurs de la sidebar sont controlees par des variables CSS, ce qui
#' offre trois niveaux de personnalisation :
#'
#' **Niveau 1 — automatique via le theme bslib :**
#' La couleur des boutons suit `primary` du theme sans rien faire.
#' ```r
#' page_sidebarHL(theme = bs_theme(primary = "#e74c3c"), ...)
#' ```
#'
#' **Niveau 2 — parametres R :**
#' Pour controler les couleurs independamment du theme global.
#' ```r
#' page_sidebarHL(nav_bg = "#e74c3c", nav_sub_bg = "#4a1010", ...)
#' ```
#'
#' **Niveau 3 — variables CSS directement :**
#' Pour un controle maximal, surcharger les variables dans `tags$style()`.
#' Les variables disponibles : `--hl-nav-bg`, `--hl-nav-sub-bg`.
#' ```r
#' page_sidebarHL(
#'   ...,
#'   shiny::tags$style(":root {
#'     --hl-nav-bg:     #e74c3c;
#'     --hl-nav-sub-bg: #4a1010;
#'   }")
#' )
#' ```
#' Voir `inst/dev/personnalisation.R` pour des exemples complets.
#'
#' @return Un tag Shiny utilisable comme UI.
#'
#' @export
page_sidebarHL <- function(
    ...,
    title           = NULL,
    theme           = NULL,
    sidebar_width   = 250,
    selected        = NULL,
    sidebar_open    = "always",
    window_title    = NA,
    protegR2_compat = FALSE,
    nav_bg          = NULL,
    nav_sub_bg      = NULL
) {
  items <- list(...)

  # Séparer les items de nav des autres (ex: hl_dropdown_panel, tags$style)
  is_nav    <- vapply(items, inherits, logical(1), c("hl_nav_panel", "hl_nav_group"))
  nav_items <- items[is_nav]
  extras    <- items[!is_nav]

  if (length(nav_items) == 0L) {
    stop(
      "page_sidebarHL() requiert au moins un hl_nav_panel() ou hl_nav_group().",
      call. = FALSE
    )
  }

  # Valeur sélectionnée par défaut (NULL → premier panneau)
  if (is.null(selected)) selected <- find_first_value(nav_items)

  # HTML de la sidebar
  sidebar_content <- build_sidebar_html(nav_items, selected)

  # Zone de contenu : navset_hidden piloté depuis la sidebar
  nav_panels   <- build_nav_panels(nav_items)
  content_area <- do.call(
    bslib::navset_hidden,
    c(nav_panels, list(id = "hl__content", selected = selected))
  )

  # Titre de la fenêtre
  win_title <- if (is.na(window_title) && is.character(title)) title else window_title

  # ── Niveau 1 : suivi automatique du thème bslib ──────────────────────────
  # Si aucun nav_bg fourni mais qu'un thème est passé, on extrait la couleur
  # primary en R (plus fiable que var(--bs-primary) en CSS qui peut se
  # résoudre à une valeur inattendue selon le bootswatch).
  if (is.null(nav_bg) && !is.null(theme)) {
    nav_bg <- tryCatch(
      bslib::bs_get_variables(theme, "primary")[["primary"]],
      error = function(e) NULL
    )
  }

  # ── Surcharges de couleurs via variables CSS ──────────────────────────────
  # Construit un bloc <style> uniquement si au moins un paramètre est fourni.
  color_vars <- c(
    if (!is.null(nav_bg))     paste0("--hl-nav-bg: ",     nav_bg,     ";"),
    if (!is.null(nav_sub_bg)) paste0("--hl-nav-sub-bg: ", nav_sub_bg, ";")
  )
  custom_colors_css <- if (length(color_vars) > 0L) {
    htmltools::tags$style(htmltools::HTML(
      paste0(":root { ", paste(color_vars, collapse = " "), " }")
    ))
  }

  # ── CSS compatibilité protegR2 ────────────────────────────────────────────
  protegr2_css <- if (isTRUE(protegR2_compat)) {
    htmltools::tags$style(htmltools::HTML("
      .protegr2-logout-fixed { display: none !important; }
      .protegr2-idioma-fixed  { display: none !important; }
    "))
  }

  bslib::page_sidebar(
    title   = title,
    sidebar = bslib::sidebar(
      sidebar_content,
      width = sidebar_width,
      open  = sidebar_open,
      class = "hl-sidebar"
    ),
    custom_colors_css,
    protegr2_css,
    content_area,
    do.call(htmltools::tagList, extras),
    hl_html_dependency(),
    theme        = theme,
    window_title = win_title
  )
}
