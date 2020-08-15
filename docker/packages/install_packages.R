# installing package imports packages
pkg_list <- c("dplyr",
              "tibble",
              "devtools",
              "here",
              "lubridate",
              "magrittr",
              "purrr",
              "rmarkdown",
              "flexdashboard",
              "tidyr",
              "leaflet",
              "leafpop")

install.packages(pkgs = pkg_list, repos = "https://cran.rstudio.com/")

fail <- FALSE

for(i in pkg_list){

  if(i %in% rownames(installed.packages())){
    cat(i, "...OK\n")
  } else {
    cat(i, "...Fail\n")
    fail <- TRUE
  }
  
  if(fail){
    stop("Fail to install some package/s")
  }
}

