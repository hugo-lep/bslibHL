# Fonctions internes — non exportées

# Retourne le value du premier hl_nav_panel (en cherchant dans les groupes)
find_first_value <- function(nav_items) {
  for (item in nav_items) {
    if (inherits(item, "hl_nav_panel")) {
      return(item$value)
    } else if (inherits(item, "hl_nav_group")) {
      result <- find_first_value(item$children)
      if (!is.null(result)) return(result)
    }
  }
  NULL
}

# Construit le HTML de la sidebar (boutons de navigation)
build_sidebar_html <- function(nav_items, selected) {
  children <- lapply(nav_items, function(item) {
    if (inherits(item, "hl_nav_panel")) {
      build_nav_btn(item, selected)
    } else if (inherits(item, "hl_nav_group")) {
      build_nav_group_html(item, selected)
    }
  })
  do.call(htmltools::tagList, children)
}

# Construit un bouton de nav pour un hl_nav_panel
build_nav_btn <- function(panel, selected) {
  is_active <- identical(panel$value, selected)
  label <- if (!is.null(panel$icon)) {
    htmltools::tagList(panel$icon, " ", panel$title)
  } else {
    panel$title
  }
  htmltools::tags$button(
    class      = paste0("hl-nav-btn", if (is_active) " active" else ""),
    `data-value` = panel$value,
    label
  )
}

# Construit un groupe collapsible avec ses boutons enfants
build_nav_group_html <- function(group, selected) {
  child_values <- vapply(group$children, function(ch) ch$value, character(1))
  any_active   <- selected %in% child_values

  label <- if (!is.null(group$icon)) {
    htmltools::tagList(group$icon, " ", group$title)
  } else {
    group$title
  }

  children_html <- lapply(group$children, build_nav_btn, selected = selected)

  is_open <- any_active || isTRUE(group$expanded)

  htmltools::tagList(
    htmltools::tags$button(
      class = paste0(
        "hl-nav-group-btn",
        if (any_active) " has-active-child" else "",
        if (is_open)    " expanded"         else ""
      ),
      label,
      htmltools::tags$span(class = "hl-nav-group-arrow", "\u25bc")
    ),
    htmltools::tags$div(
      class = "hl-nav-group-children",
      style = if (is_open) "" else "display:none;",
      do.call(htmltools::tagList, children_html)
    )
  )
}

# Extrait les bslib::nav_panel() depuis la liste d'items (récursif)
build_nav_panels <- function(nav_items) {
  panels <- list()
  for (item in nav_items) {
    if (inherits(item, "hl_nav_panel")) {
      panels[[length(panels) + 1L]] <- bslib::nav_panel(
        title = item$title,
        value = item$value,
        htmltools::div(
          class = "html-fill-container html-fill-item",
          style = "overflow-y: auto; min-height: 0;",
          do.call(htmltools::tagList, item$content)
        )
      )
    } else if (inherits(item, "hl_nav_group")) {
      for (child in item$children) {
        panels[[length(panels) + 1L]] <- bslib::nav_panel(
          title = child$title,
          value = child$value,
          htmltools::div(
            class = "html-fill-container html-fill-item",
            style = "overflow-y: auto; min-height: 0;",
            do.call(htmltools::tagList, child$content)
          )
        )
      }
    }
  }
  panels
}

# Dépendance HTML (CSS + JS embarqués dans inst/www/)
hl_html_dependency <- function() {
  # En développement (load_all), packageVersion reste à 0.1.0 et le navigateur
  # sert une version cachée du CSS. On ajoute un sous-numéro basé sur la date
  # de modification du fichier CSS pour forcer le rechargement à chaque changement.
  css_path <- system.file("www/hl-styles.css", package = "bslibHL")
  mtime    <- as.integer(file.info(css_path)$mtime)
  version  <- paste0(utils::packageVersion("bslibHL"), ".", mtime)

  htmltools::htmlDependency(
    name       = "bslibHL",
    version    = version,
    src        = system.file("www", package = "bslibHL"),
    script     = "hl-nav.js",
    stylesheet = "hl-styles.css"
  )
}
