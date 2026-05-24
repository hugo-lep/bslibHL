# ══════════════════════════════════════════════════════════════════════════════
# inst/dev/personnalisation.R
#
# Référence complète pour personnaliser l'apparence de page_sidebarHL().
# Trois niveaux disponibles — du plus simple au plus granulaire.
# ══════════════════════════════════════════════════════════════════════════════

library(devtools)
load_all()

# ── Contenu commun aux exemples ────────────────────────────────────────────
pages_demo <- list(
  hl_nav_panel("Accueil", icon = shiny::icon("house"),
    shiny::h2("Accueil"), shiny::p("Page d'accueil.")
  ),
  hl_nav_group("Rapports", icon = shiny::icon("chart-bar"),
    hl_nav_panel("Mensuel",  shiny::h2("Rapport mensuel")),
    hl_nav_panel("Annuel",   shiny::h2("Rapport annuel"))
  ),
  hl_nav_panel("Paramètres", icon = shiny::icon("gear"),
    shiny::h2("Paramètres")
  )
)

server_demo <- function(input, output, session) {
  page_sidebarHL_server(session)
}


# ══════════════════════════════════════════════════════════════════════════════
# NIVEAU 1 — Automatique via le thème bslib
# ──────────────────────────────────────────
# Les boutons de la sidebar suivent automatiquement la couleur `primary`
# du thème bs_theme(). Rien à faire côté bslibHL.
# ══════════════════════════════════════════════════════════════════════════════

ui_niveau1 <- do.call(page_sidebarHL, c(pages_demo, list(
  title = "Niveau 1 — Thème bslib",
  theme = bslib::bs_theme(
    bootswatch = "darkly",
    primary    = "#e74c3c"    # ← les boutons sidebar deviennent rouges automatiquement
  )
)))

shiny::shinyApp(ui_niveau1, server_demo)


# ══════════════════════════════════════════════════════════════════════════════
# NIVEAU 2 — Paramètres R de page_sidebarHL()
# ────────────────────────────────────────────
# Pour choisir les couleurs indépendamment du thème global.
# hover et active sont calculés automatiquement (filter: brightness).
#
# Paramètres disponibles :
#   nav_bg     — couleur des boutons principaux (Accueil, groupes, Paramètres)
#   nav_sub_bg — couleur des sous-items (enfants d'un hl_nav_group)
#   badge_bg   — couleur des badges (messages, notifications)
# ══════════════════════════════════════════════════════════════════════════════

ui_niveau2 <- do.call(page_sidebarHL, c(pages_demo, list(
  title      = "Niveau 2 — Paramètres R",
  theme      = bslib::bs_theme(bootswatch = "darkly"),
  nav_bg     = "#27ae60",   # vert
  nav_sub_bg = "#1a5c35",   # vert foncé pour les sous-items
  badge_bg   = "#f39c12",   # orange pour les badges
  header_items = list(
    hl_badge_button("notif", shiny::icon("bell"), count = 3)
  )
)))

shiny::shinyApp(ui_niveau2, server_demo)


# ══════════════════════════════════════════════════════════════════════════════
# NIVEAU 3 — Variables CSS directement
# ──────────────────────────────────────
# Pour un contrôle maximal. Passer un tags$style() dans le ... de
# page_sidebarHL(). Utile quand on veut modifier des aspects que les
# paramètres R n'exposent pas (ex: border-radius, font-size, padding).
#
# Variables CSS disponibles :
#   --hl-nav-bg      → fond des boutons principaux
#   --hl-nav-sub-bg  → fond des sous-items
#   --hl-badge-bg    → fond des badges
#
# Propriétés CSS modifiables directement (classes) :
#   .hl-nav-btn            → boutons principaux
#   .hl-nav-group-btn      → boutons de groupe
#   .hl-nav-group-children .hl-nav-btn → sous-items
#   .hl-header-btn         → boutons du header
#   .hl-badge              → badge numérique
#   .hl-dropdown-panel     → panneau dropdown
# ══════════════════════════════════════════════════════════════════════════════

ui_niveau3 <- do.call(page_sidebarHL, c(pages_demo, list(
  title = "Niveau 3 — Variables CSS",
  theme = bslib::bs_theme(bootswatch = "darkly"),

  # tags$style() passé dans ... de page_sidebarHL()
  shiny::tags$style(shiny::HTML("
    :root {
      --hl-nav-bg:     #8e44ad;   /* violet          */
      --hl-nav-sub-bg: #4a235a;   /* violet foncé    */
      --hl-badge-bg:   #e67e22;   /* orange          */
    }

    /* Personnalisation plus fine impossible via paramètres R */
    .hl-nav-btn {
      border-radius: 0;           /* boutons carrés  */
      font-size: 0.85rem;
    }
    .hl-nav-group-btn {
      border-radius: 0;
    }
  "))
)))

shiny::shinyApp(ui_niveau3, server_demo)


# ══════════════════════════════════════════════════════════════════════════════
# COMBINAISON — Niveaux 2 + 3 ensemble
# ──────────────────────────────────────
# Les paramètres R (nav_bg, nav_sub_bg) et tags$style() peuvent coexister.
# Les variables CSS dans tags$style() ont priorité sur les paramètres R.
# ══════════════════════════════════════════════════════════════════════════════

ui_combo <- do.call(page_sidebarHL, c(pages_demo, list(
  title      = "Combinaison niveaux 2 + 3",
  theme      = bslib::bs_theme(bootswatch = "darkly"),
  nav_bg     = "#2980b9",   # bleu via paramètre R
  # tags$style() écrase nav_bg pour les sous-items uniquement
  shiny::tags$style(shiny::HTML("
    :root { --hl-nav-sub-bg: #1a3a4a; }
  "))
)))

shiny::shinyApp(ui_combo, server_demo)
