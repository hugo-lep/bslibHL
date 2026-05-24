renv::install(c("devtools", "roxygen2", "testthat", "knitr"))
use_package("shiny")

library(devtools)
load_all()
document()
check()

renv::install("bsicons")
