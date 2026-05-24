#' Logique serveur de page_sidebarHL
#'
#' A appeler une fois dans le `server` de l'application. Gere :
#' \itemize{
#'   \item Le routing sidebar -> contenu (`nav_select()`)
#'   \item La mise a jour de l'URL a chaque navigation (`?page=valeur`)
#' }
#'
#' Lorsque utilise avec protegR2, appeler depuis
#' `protegR2_load_modules_servers()` en passant la session principale.
#'
#' @section Inputs Shiny exposes:
#'
#' Deux inputs sont disponibles cote serveur pour reagir a la navigation :
#'
#' **`input$hl__nav`** — declenche uniquement par un clic utilisateur dans la
#' sidebar. Vaut `NULL` au demarrage (avant tout clic). Utile pour reagir a
#' une action explicite de l'utilisateur :
#' ```r
#' observeEvent(input$hl__nav, {
#'   # declenche seulement quand l'utilisateur clique
#' })
#' ```
#'
#' **`input$hl__content`** — expose automatiquement par bslib via
#' `navset_hidden(id = "hl__content")`. Initialise avec la page selectionnee
#' au demarrage, puis mis a jour a chaque navigation (clic OU `hl_nav_select()`).
#' A privilegier quand on a besoin de connaitre la page active a tout moment :
#' ```r
#' observe({
#'   page <- input$hl__content   # jamais NULL, valide des le demarrage
#' })
#' ```
#'
#' Ces deux inputs sont distincts de `input$nav_tab` utilise par protegR2 pour
#' ses propres layouts — aucun conflit.
#'
#' @param session Objet session Shiny. Par defaut la session courante.
#'
#' @export
page_sidebarHL_server <- function(session = shiny::getDefaultReactiveDomain()) {

  # ── Routing : clic sidebar → nav_select() ─────────────────────────────────
  shiny::observeEvent(
    session$input[["hl__nav"]],
    {
      bslib::nav_select("hl__content", selected = session$input[["hl__nav"]])
    },
    ignoreInit = TRUE
  )

  # ── URL tracking : navigation → mise à jour de l'URL ──────────────────────
  #
  # Synchronise l'URL du navigateur avec la page active.
  # Permet la restauration de l'onglet actif après un refresh ou un auto-login.
  #
  # mode = "push" : ajoute une entrée dans l'historique du navigateur
  #   → le bouton "précédent" fonctionne comme attendu.
  #
  # Utilisation dans protegR2_load_modules_UIs() pour restaurer l'onglet :
  #   selected = isolate(shiny::getQueryString(session))$page
  shiny::observeEvent(
    session$input[["hl__nav"]],
    {
      shiny::updateQueryString(
        paste0("?page=", session$input[["hl__nav"]]),
        mode    = "push",
        session = session
      )
    },
    ignoreInit = TRUE
  )
}


#' Changer de page depuis le serveur
#'
#' Change la page active de [page_sidebarHL()] depuis le code serveur, en
#' mettant a jour simultanement :
#' \itemize{
#'   \item Le contenu affiche (`navset_hidden`)
#'   \item L'etat visuel actif dans la sidebar (classes CSS)
#'   \item L'URL du navigateur (`?page=valeur`)
#' }
#'
#' A utiliser a la place d'un appel direct a `bslib::nav_select()` qui, lui,
#' ne mettrait pas a jour les classes CSS de la sidebar ni l'URL.
#'
#' Apres appel, `input$hl__content` reflete la nouvelle page. `input$hl__nav`
#' ne se declenche pas (il est reserve aux clics utilisateur).
#'
#' @param value Valeur (`value`) du [hl_nav_panel()] a activer.
#' @param session Objet session Shiny. Par defaut la session courante.
#'
#' @export
hl_nav_select <- function(value, session = shiny::getDefaultReactiveDomain()) {
  bslib::nav_select("hl__content", selected = value)
  session$sendCustomMessage("hl_set_active", list(value = value))
  shiny::updateQueryString(
    paste0("?page=", value),
    mode    = "push",
    session = session
  )
}

