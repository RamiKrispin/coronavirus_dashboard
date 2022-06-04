#' Create a Confirmed/Death Plot
#' @description The function creates a two dimension (log-scale) plot describing 
#' the relationship between number of confirmed and death cases in each country.
#' The plot insipired by the John Hopkins University mortality plot - 
#' https://coronavirus.jhu.edu/data/mortality




mortality_plot <- function(coronavirus_agg = coronavirus_agg(),
                           per_line_color = "gray",
                           per_line_width = 0.4,
                           per_line_start = 1300,
                           margin = list(r = 20, l = 20, t = 0, b = 20)){
  `%>%` <- magrittr::`%>%`


  
  
  
  d1 <- data.frame(x = c(1000, 100 * 10 ^ 6),
                   y = c(0.005 * 1000, 0.005 * 100 * 10 ^ 6))

  
  
  df_top20 <- coronavirus_agg %>% dplyr::arrange(- death_per_100k) %>%
    dplyr::slice_head(n = 20)
  
  
  
  df_rest <- coronavirus_agg %>% dplyr::arrange(- death_per_100k) %>%
    dplyr::filter(dplyr::row_number() > 20)
  
  
  
  p <- plotly::plot_ly() %>%
    plotly::add_markers(x = df_top20$confirmed,
                        y = df_top20$death,
                        hoverinfo = "text",
                        text = paste(df_top20$location, "<br>",
                                     "Total Cases: ", df_top20$confirmed, "<br>",
                                     "Total Deaths: ", df_top20$death, "<br>",
                                     "Death / Cases Ratio: ", round(100 * df_top20$death / df_top20$confirmed, 1) , "%",  "<br>",
                                     "Death Per 100k: ", round(df_top20$death_per_100k), 
                                     sep = ""),
                        marker = list(color = "orange",
                                      line = list(color = "black", width = 1)),
                        name = "Top 20 Countries (Death Per 100K)",
                        showlegend = TRUE) %>%
    plotly::add_markers(x = df_rest$confirmed,
                        y = df_rest$death,
                        hoverinfo = "text",
                        text = paste(df_rest$location, "<br>",
                                     "Total Cases: ", df_rest$confirmed, "<br>",
                                     "Total Deaths: ", df_rest$death, "<br>",
                                     "Death / Cases Ratio: ", round(100 * df_rest$death / df_rest$confirmed, 1) , "%",  "<br>",
                                     "Death Per 100k: ", round(df_rest$death_per_100k), 
                                     sep = ""),
                        marker = list(color = "orange"),
                        name = "Rest of the World",
                        showlegend = TRUE) %>%
    plotly::add_lines(x = c(per_line_start, 100 * 10 ^ 6),
                      y = c(0.005 * per_line_start, 0.005 * 100 * 10 ^ 6),
                      showlegend = FALSE,
                      line = list(color = per_line_color, width = per_line_width)) %>%
    plotly::add_annotations(text = "0.5%",
                            x = log10(round(max(coronavirus_agg$confirmed) + 50 * 10 ^ 6)),
                            y = log10((0.005 + 0.001) * 100 * 10 ^ 6),
                            showarrow = FALSE,
                            textangle = -25,
                            xref = "x",
                            yref = "y") %>%
    plotly::add_annotations(text = "1%",
                            x = log10(round(max(coronavirus_agg$confirmed) + 50 * 10 ^ 6)),
                            y = log10((0.01 + 0.001) * 100 * 10 ^ 6),
                            showarrow = FALSE,
                            textangle = -25,
                            xref = "x",
                            yref = "y") %>%
    plotly::add_annotations(text = "2%",
                            x = log10(round(max(coronavirus_agg$confirmed) + 50 * 10 ^ 6)),
                            y = log10((0.02 + 0.001) * 100 * 10 ^ 6),
                            showarrow = FALSE,
                            textangle = -25,
                            xref = "x",
                            yref = "y") %>%
    plotly::add_annotations(text = "5%",
                            x = log10(round(max(coronavirus_agg$confirmed) + 50 * 10 ^ 6)),
                            y = log10((0.05 + 0.001) * 100 * 10 ^ 6),
                            showarrow = FALSE,
                            textangle = -25,
                            xref = "x",
                            yref = "y",
                            showlegend = FALSE) %>%
    plotly::add_annotations(text = "10%",
                            x = log10(round(max(coronavirus_agg$confirmed) + 50 * 10 ^ 6)),
                            y = log10((0.1 + 0.001) * 100 * 10 ^ 6),
                            showarrow = FALSE,
                            textangle = -25,
                            xref = "x",
                            yref = "y") %>%
    plotly::add_lines(x = c(per_line_start, 100 * 10 ^ 6),
                      y = c(0.01 * per_line_start, 0.01 * 100 * 10 ^ 6),
                      showlegend = FALSE,
                      line = list(color = per_line_color, width = per_line_width)) %>%
    plotly::add_lines(x = c(per_line_start, 100 * 10 ^ 6),
                      y = c(0.02 * per_line_start, 0.02 * 100 * 10 ^ 6),
                      showlegend = FALSE,
                      line = list(color = per_line_color, width = per_line_width)) %>%
    plotly::add_lines(x = c(per_line_start, 100 * 10 ^ 6),
                      y = c(0.05 * per_line_start, 0.05 * 100 * 10 ^ 6),
                      showlegend = FALSE,
                      line = list(color = per_line_color, width = per_line_width)) %>%
    plotly::add_lines(x = c(per_line_start, 100 * 10 ^ 6),
                      y = c(0.1 * per_line_start, 0.1 * 100 * 10 ^ 6),
                      showlegend = FALSE,
                      line = list(color = per_line_color, width = per_line_width)) %>%
    plotly::layout(yaxis = list(title = "Deaths",
                                type = 'log',
                                zerolinecolor = '#ffff',
                                zerolinewidth = 2,
                                # tick0=0.25, dtick=0.5,
                                dtick=1,
                                gridcolor = 'ffff'),
                   xaxis = list(title = "Confirmed Cases",
                                type = 'log',
                                range = c(log10(1000), log10(round(max(coronavirus_agg$confirmed) + 50 * 10 ^ 6))),
                                zerolinecolor = '#ffff',
                                zerolinewidth = 2,
                                dtick=1,
                                gridcolor = 'ffff'),
                   margin = margin,
                   legend = list(x = 0.05, y = 0.95))
  
  return(p)
}


#' Get Worldwide GIS Codes
#' @description The function pull from the John Hopkins Coronavirus repo a table with most common GIS codes per 
#' country (i.e., uid, iso2, iso3, etc.)
#' @param url The table raw URL


get_gis_codes <- function(url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/UID_ISO_FIPS_LookUp_Table.csv"){
  gis_codes <- readr::read_csv(url, 
                               col_types = readr::cols(FIPS = readr::col_number(),
                                                       Admin2 = readr::col_character())
  )
  names(gis_codes) <- tolower(names(gis_codes))
  names(gis_codes)[which(names(gis_codes) == "long_")] <- "long"
  return(gis_codes)
} 


#' Data Transformation
#' @description A transforming function for the coronavirus dataset 
#' 


coronavirus_agg <- function(coronavirus_jhu = coronavirus::refresh_coronavirus_jhu(),
         gis_codes = get_gis_codes()){
  
  df <- coronavirus_jhu %>%
    dplyr::filter(location_type == "country") %>%
    dplyr::left_join(gis_codes %>% 
                       dplyr::filter(is.na(province_state)) %>%
                       dplyr::filter(country_region == combined_key) %>%
                       dplyr::select(location = country_region, population), 
                     by = c("location"))
  
  
  df_agg <- df %>% 
    dplyr::filter(location_type == "country",
                  data_type != "recovered_new") %>%
    # dplyr::filter(location == combined_key ) %>%
    tidyr::pivot_wider(names_from = data_type, values_from = value) %>%
    dplyr::group_by(location) %>%
    dplyr::summarise(confirmed = sum(cases_new),
                     death = sum(deaths_new)) %>%
    dplyr::arrange(- death) %>%
    dplyr::left_join(gis_codes %>% 
                       dplyr::filter(is.na(province_state)) %>%
                       dplyr::select(location = combined_key, population) %>% 
                       dplyr::distinct(),
                     by = "location") %>%
    dplyr::mutate(rate = death / confirmed,
                  rate_pop = death / population,
                  death_per_100k = death / (population / 100000)) %>%
    dplyr::arrange(-death_per_100k) %>%
    dplyr::filter(!is.na(population))
  
  return(df_agg)
}