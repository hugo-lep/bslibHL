# CLAUDE.md — bslibHL

## Rôle de Claude dans ce projet

Tu es un programmeur-analyste spécialisé R/Shiny. Ce projet est une interface UI sur mesure destinée à être utilisée dans plusieurs applications Shiny. Ton travail est de concevoir des fonctions R propres, réutilisables, bien documentées, et parfaitement compatibles avec l'écosystème bslib + protegR2.

---

## Profil du développeur

**Hugo Lepage** — développeur R, communique en français. Autres packages actifs :
- `protegR2` — authentification/sessions Shiny (S3 + cookies)
- `stockToolsR` — analyse financière (FMP API + Yahoo via quantmod + postgres)
- `utilsHL`, `s3db`, `kiwiR` — packages utilitaires personnels

Style de code : tidyverse, pipes `%>%`, commentaires en français, documentation roxygen en français (sans accents dans les balises).

---

## Vision du projet bslibHL

**Problème résolu :** `bslib::page_sidebar()` est excellent pour une page unique, mais ne gère pas le multi-page nativement. `shinydashboard` offre le bon pattern (sidebar de navigation + multi-page) mais repose sur Bootstrap 3 désuet. `bslib::page_navbar()` fait du multi-page mais sans sidebar persistante.

**Solution :** `page_sidebarHL()` — un layout dashboard qui combine :
- La sidebar persistante de `page_sidebar()`
- La navigation multi-page de `page_navbar()`
- Groupes de pages collapsibles dans la sidebar

**Principe clé : rester personnalisable.** Les couleurs, thèmes, largeurs, icônes doivent tous être configurables par l'utilisateur via des paramètres explicites. Ne jamais hardcoder de valeurs cosmétiques dans la logique des fonctions — les mettre dans le CSS avec des variables CSS autant que possible, ou comme paramètres R.

---

## Architecture du package

### Fonctions publiques

| Fonction | Rôle |
|---|---|
| `page_sidebarHL(...)` | Layout principal — `nav_bg`, `nav_sub_bg` pour les couleurs sidebar |
| `hl_nav_panel(title, ..., icon, value)` | Définit une page (bouton sidebar + contenu) |
| `hl_nav_group(title, ..., icon, expanded)` | Groupe collapsible de pages dans la sidebar |
| `hl_theme(primary, bootswatch, ...)` | Thème bslib pré-configuré (darkly + #3c8dbc) |
| `page_sidebarHL_server(session)` | Routing + URL tracking — appeler 1x dans server() |
| `hl_nav_select(value, session)` | Changer de page depuis le server (MAJ sidebar + contenu + URL) |

### Ce qui N'est PAS dans bslibHL

Les composants suivants ont été **migrés dans protegR2** pour être disponibles avec n'importe quel `bslib::page_*`, pas seulement `page_sidebarHL()` :

- `protegr2_badge_button()` — bouton header avec badge animé
- `protegr2_dropdown_panel()` — panneau dropdown (messages, notifications)
- `protegr2_update_badge()` — MAJ dynamique du badge depuis le server

bslibHL ne dépend pas de protegR2, et protegR2 ne dépend pas de bslibHL.

### Paramètre `title` et header personnalisé

`page_sidebarHL()` n'a plus de paramètre `header_items`. Pour ajouter des éléments à droite dans le header (badges, bouton logout, etc.), passer un tag HTML complet comme `title` en utilisant les classes CSS fournies par bslibHL :

```r
page_sidebarHL(
  title = htmltools::tags$div(
    class = "hl-header-wrapper",
    htmltools::tags$span(class = "hl-header-title", "Mon App"),
    htmltools::tags$div(
      class = "hl-header-items",
      protegR2::protegr2_badge_button("notif", shiny::icon("bell"), count = 0, panel_id = "notif_panel"),
      shiny::actionButton("logout", ..., class = "pr2-header-btn btn-sm")
    )
  ),
  ...
)
```

Classes CSS disponibles : `hl-header-wrapper` (flex row), `hl-header-title` (prend l'espace restant), `hl-header-items` (flex row, flex-shrink: 0).

### Mécanisme de routing

- Contenu = `bslib::navset_hidden(id = "hl__content")`
- Clic sidebar → JS → `Shiny.setInputValue("hl__nav", value, {priority: "event"})`
- `page_sidebarHL_server()` écoute `hl__nav` → `bslib::nav_select("hl__content", selected)` + `updateQueryString()`
- `hl_nav_select(value, session)` pour navigation programmatique → MAJ contenu + sidebar CSS + URL
- L'input `hl__nav` est disponible côté serveur pour les `observeEvent()`

### Fichiers

```
R/
  page_sidebarHL.R          # Fonction principale (title, theme, nav_bg, nav_sub_bg, ...)
  hl_nav_panel.R            # Définit une page
  hl_nav_group.R            # Groupe collapsible
  hl_theme.R                # Thème bslib par défaut (darkly + #3c8dbc)
  page_sidebarHL_server.R   # page_sidebarHL_server() + hl_nav_select()
  utils-internal.R          # Helpers internes non exportés + hl_html_dependency()
inst/www/
  hl-nav.js                 # Routing sidebar + hl_set_active handler
  hl-styles.css             # Styles sidebar, groupes, header layout
inst/dev/
  package_test.R            # App de démo (load_all + shinyApp)
```

---

## Compatibilité avec protegR2

**protegR2** est le package d'authentification d'Hugo. Toutes les apps Shiny d'Hugo utilisent protegR2 + bslibHL ensemble.

### Comment protegR2 fonctionne (résumé)

- `protegR2_ui()` construit une coquille statique avec `uiOutput("main_ui")`
- `protegR2_server()` gère login/logout/cookie et remplace `main_ui` selon l'état de connexion
- Après login réussi, `main_ui` est remplacé par le retour de `protegR2_load_modules_UIs(session, tr)` — une fonction copiée dans le projet utilisateur qui retourne le layout complet
- Infos utilisateur accessibles via `session$userData$user_info` :
  - `user_auth()` — reactiveVal : NULL = non connecté, username = connecté
  - `user_role()` — reactiveVal : `"user"` | `"admin"` | `"super_admin"` | `"dev"`
  - `valid_user()` — reactiveVal : liste complète des données utilisateur
  - `token_value` — UUID de session (non réactif)
- Langue courante : `session$userData$idioma()` (reactiveVal)
- Fonction de traduction : `tr("clé")` — closure sur idioma

### Éléments fixes que protegR2 injecte

protegR2 place deux éléments en `position: fixed` dans la page :
- `.protegr2-logout-fixed` — bouton "Se déconnecter" (top-right)
- `.protegr2-idioma-fixed` — sélecteur de langue (top-right)

Quand bslibHL est utilisé, passer `protegR2_compat = TRUE` à `page_sidebarHL()` pour masquer ces boutons via CSS.

### Pattern d'intégration complet dans protegR2_load_modules_UIs()

```r
protegR2_load_modules_UIs <- function(session, tr) {
  # Restaure l'onglet actif depuis l'URL après refresh ou auto-login
  page_actif <- isolate(shiny::getQueryString(session))$page

  page_sidebarHL(
    title = htmltools::tags$div(
      class = "hl-header-wrapper",
      htmltools::tags$span(class = "hl-header-title", "Mon App"),
      htmltools::tags$div(
        class = "hl-header-items",
        protegr2_lang_dropdown(session$userData$config_global, session$userData$idioma()),
        protegR2::protegr2_badge_button("notif", shiny::icon("bell"), count = 0, panel_id = "notif_panel"),
        shiny::actionButton(
          "logout",
          label = shiny::tagList(shiny::icon("right-from-bracket"), tr("logout")),
          class = "pr2-header-btn btn-sm"
        )
      )
    ),
    protegR2_compat = TRUE,
    selected        = page_actif,

    hl_nav_panel("Accueil", icon = shiny::icon("house"), ...),
    hl_nav_group("Rapports", icon = shiny::icon("chart-bar"),
      hl_nav_panel("Mensuel", ...),
      hl_nav_panel("Annuel", ...)
    ),
    protegR2::protegr2_dropdown_panel("notif_panel", ...)
  )
}
```

### Filtrage par rôle utilisateur

bslibHL ne gère pas les rôles — c'est à `protegR2_load_modules_UIs()` de filtrer les panels :

```r
role <- session$userData$user_info$user_role()
panels <- list(
  hl_nav_panel("Accueil", ...),
  if (role %in% c("admin", "super_admin")) hl_nav_panel("Administration", ...)
)
do.call(page_sidebarHL, c(panels, list(title = "App", protegR2_compat = TRUE)))
```

---

## Conventions de développement

- **Pas de shinyjs** — tout en JS vanilla/jQuery via la dépendance HTML embarquée
- **Préfixe `hl-`** pour les classes CSS, **`hl__`** pour les IDs internes Shiny
- **Variables CSS** (`--hl-nav-bg`, `--hl-nav-sub-bg`) pour la personnalisation des couleurs
- **Imports explicites** avec `::` (pas de `@import` dans NAMESPACE sauf si nécessaire)
- Les fonctions internes (non exportées) vivent dans `utils-internal.R`, sans `@export`
- **Ne jamais éditer `NAMESPACE` manuellement** — il est généré par `devtools::document()` depuis les tags `@export` roxygen
- Workflow : `devtools::load_all()` pour tester, `devtools::document()` pour régénérer `NAMESPACE` et `man/`
