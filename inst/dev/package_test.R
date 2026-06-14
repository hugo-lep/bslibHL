library(devtools)

load_all()
#document()
renv::snapshot()
#check()

# ── Thème ──────────────────────────────────────────────────────────────────
mon_theme <- hl_theme(base_font = bslib::font_google("Roboto"))

# ── UI ─────────────────────────────────────────────────────────────────────
ui <- page_sidebarHL(
  title = "Mon Dashboard",
  theme = mon_theme,

  # ── Pages ──
  hl_nav_panel("Accueil", icon = shiny::icon("house"),
    shiny::h2("Bienvenue !"),
    shiny::p("Voici la page d'accueil.")
  ),

  hl_nav_group("Statistiques", icon = shiny::icon("chart-line"),
    hl_nav_panel("Histogramme",
      shiny::h2("Histogramme"),
      shiny::plotOutput("mon_plot")
    ),
    hl_nav_panel("R\u00e9sum\u00e9",
      shiny::h2("R\u00e9sum\u00e9"),
      shiny::verbatimTextOutput("resume_data")
    )
  ),

  hl_nav_panel("Param\u00e8tres", icon = shiny::icon("gear"),
    shiny::h2("Param\u00e8tres"),
    shiny::checkboxInput("opt", "Option activ\u00e9e", TRUE)
  )

  # ── Dropdowns header — utiliser protegR2::protegr2_dropdown_panel() ──
  # protegR2::protegr2_dropdown_panel("msg_panel",
  #   shiny::h5("\U0001f4ec Messages"),
  #   shiny::p(shiny::strong("De :"), " Admin"),
  #   shiny::p("Bienvenue dans ce dashboard !")
  # ),
  # protegR2::protegr2_dropdown_panel("notif_panel",
  #   shiny::h5("\U0001f514 Notifications"),
  #   shiny::tags$ul(
  #     shiny::tags$li("Mise \u00e0 jour syst\u00e8me pr\u00e9vue demain."),
  #     shiny::tags$li("Nouvelle analyse disponible.")
  #   )
  # )
)

# ── Server ─────────────────────────────────────────────────────────────────
server <- function(input, output, session) {
  page_sidebarHL_server(session)

  output$mon_plot <- shiny::renderPlot({
    hist(rnorm(200), col = "#3c8dbc", border = "white",
         main = "Histogramme", xlab = "")
  })

  output$resume_data <- shiny::renderPrint({
    summary(rnorm(200))
  })
}

shiny::shinyApp(ui, server)
