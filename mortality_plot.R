`%>%` <- magrittr::`%>%`
# coronavirus::update_dataset()
# reset the session
library(coronavirus)
data("coronavirus")
max(coronavirus$date)
head(coronavirus)
table(coronavirus$continent_name, useNA = "always")
table(coronavirus$province, useNA = "always")
# df <- coronavirus %>% 
#   dplyr::filter(!is.na(continent_code),
#                 is.na(province)) 
# 
# head(df)

head(coronavirus)
gis_codes <- coronavirus %>% 
  dplyr::select(country, combined_key, continent_name, continent_code) %>%
  dplyr::distinct()

gis_codes_coronavirues <- readr::read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/UID_ISO_FIPS_LookUp_Table.csv",
                                          col_types = readr::cols(FIPS = readr::col_number(),
                                                                  Admin2 = readr::col_character()))

names(gis_codes_coronavirues) <- tolower(names(gis_codes_coronavirues))
names(gis_codes_coronavirues)[which(names(gis_codes_coronavirues) == "long_")] <- "long"
head(as.data.frame(gis_codes_coronavirues))

df <- coronavirus::refresh_coronavirus_jhu() %>%
  dplyr::left_join(gis_codes, by = c("location" = "country"))




nrow(df)
max(df$date)

head(df)
# head(df_cases)
# unique(df_cases$province)
# table(df_cases$province, useNA = "always")
# unique(df_cases$country)

# df <- df_cases %>% dplyr::filter(is.na(province),
#                                  type != "recovery") %>%
#   dplyr::select(date, country, type, cases, population) %>%
#   tidyr::pivot_wider(names_from = type, values_from = cases)
# head(df)
# tail(df)

combined_key == "United Kingdom"

df_agg <- df %>% 
  dplyr::filter(location_type == "country",
                data_type != "recovered_new") %>%
  dplyr::filter(location == combined_key ) %>%
  tidyr::pivot_wider(names_from = data_type, values_from = value) %>%
  dplyr::group_by(location) %>%
  dplyr::summarise(confirmed = sum(cases_new),
                   death = sum(deaths_new)) %>%
  dplyr::arrange(- death) %>%
  dplyr::left_join(gis_code_mapping %>% 
                     dplyr::filter(is.na(province_state)) %>%
                     dplyr::select(location = combined_key, population) %>% 
                     dplyr::distinct(),
                   by = "location") %>%
  dplyr::mutate(rate = death / confirmed,
                rate_pop = death / population,
                death_per_100k = death / (population / 1000000)) %>%
  dplyr::arrange(-death_per_100k) %>%
  dplyr::filter(!is.na(population))
head(df_agg, 20)


table(is.na(df_agg$population))
d1 <- data.frame(x = c(1000, 100 * 10 ^ 6),
y = c(0.005 * 1000, 0.005 * 100 * 10 ^ 6))

per_line_color <- "gray"
per_line_width <- 0.4
per_line_start <- 1300


df_top20 <- df_agg %>% dplyr::arrange(- death_per_100k) %>%
  dplyr::slice_head(n = 20)


df_top20


df_rest <- df_agg %>% dplyr::arrange(- death_per_100k) %>%
  dplyr::filter(dplyr::row_number() > 20)

head(df_rest)

plotly::plot_ly() %>%
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
                      showlegend = FALSE) %>%
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
                      showlegend = FALSE) %>%
  plotly::add_lines(x = c(per_line_start, 100 * 10 ^ 6),
                    y = c(0.005 * per_line_start, 0.005 * 100 * 10 ^ 6),
                    showlegend = FALSE,
                    line = list(color = per_line_color, width = per_line_width)) %>%
  plotly::add_annotations(text = "0.5%",
                          x = log10(round(max(df_agg$confirmed) + 50 * 10 ^ 6)),
                          y = log10((0.005 + 0.001) * 100 * 10 ^ 6),
                          showarrow = FALSE,
                          textangle = -25,
                          xref = "x",
                          yref = "y") %>%
  plotly::add_annotations(text = "1%",
                          x = log10(round(max(df_agg$confirmed) + 50 * 10 ^ 6)),
                          y = log10((0.01 + 0.001) * 100 * 10 ^ 6),
                          showarrow = FALSE,
                          textangle = -25,
                          xref = "x",
                          yref = "y") %>%
  plotly::add_annotations(text = "2%",
                          x = log10(round(max(df_agg$confirmed) + 50 * 10 ^ 6)),
                          y = log10((0.02 + 0.001) * 100 * 10 ^ 6),
                          showarrow = FALSE,
                          textangle = -25,
                          xref = "x",
                          yref = "y") %>%
  plotly::add_annotations(text = "5%",
                          x = log10(round(max(df_agg$confirmed) + 50 * 10 ^ 6)),
                          y = log10((0.05 + 0.001) * 100 * 10 ^ 6),
                          showarrow = FALSE,
                          textangle = -25,
                          xref = "x",
                          yref = "y",
                          showlegend = FALSE) %>%
  plotly::add_annotations(text = "10%",
                          x = log10(round(max(df_agg$confirmed) + 50 * 10 ^ 6)),
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
  plotly::layout(yaxis = list(title = "Death",
                              type = 'log',
                              zerolinecolor = '#ffff',
                              zerolinewidth = 2,
                              # tick0=0.25, dtick=0.5,
                              dtick=1,
                              gridcolor = 'ffff'),
                 xaxis = list(title = "Confirmed Cases",
                              type = 'log',
                              range = c(log10(1000), log10(round(max(df_agg$confirmed) + 50 * 10 ^ 6))),
                              zerolinecolor = '#ffff',
                              zerolinewidth = 2,
                              dtick=1,
                              gridcolor = 'ffff'),
                 margin = list(r = 60, l = 60, t = 20, b = 70))


head(df)
head(df_agg)

df_tree <- df_agg %>% 
  dplyr::select(country, confirmed, death) %>%
  tidyr::pivot_longer(cols = -country) %>%
  dplyr::mutate(perent = dplyr::if_else(name == "confirmed", "Confirmed", "Death"))
  
  
plotly::plot_ly(
  data = df_tree %>% dplyr::filter(name == "confirmed"),
  type= "treemap",
  values = ~value,
  labels= ~ country,
  parents=  ~ perent,
  domain = list(column=0),
  name = "Confirmed",
  textinfo="label+value+percent parent"
)  %>%
  plotly::add_trace(
    data = df_tree %>% dplyr::filter(name == "death"),
    type= "treemap",
    values = ~ value,
    labels= ~ country,
    parents=  ~ perent,
    domain = list(column=1),
    name = "Death",
    textinfo="label+value+percent parent"
  ) %>%
  plotly::layout(grid=list(columns=2, rows=1))




df_cases_c <- df_cases %>% 
  dplyr::group_by(date, continent_name, continent_code, type) %>%
  dplyr::summarise(total = sum(cases),
                   .groups = "drop") %>%
  dplyr::filter(type != "recovery") %>%
  dplyr::filter(!is.na(continent_name))

# Smooting outlier
df_cases_c$total[which(df_cases_c$date == as.Date("2021-05-20") & 
                         df_cases_c$type == "confirmed" &
                         df_cases_c$continent_name == "Europe")] <- (df_cases_c$total[which(df_cases_c$date == as.Date("2021-05-19") & 
                                                                                              df_cases_c$type == "confirmed" &
                                                                                              df_cases_c$continent_name == "Europe")] + 
                                                                       df_cases_c$total[which(df_cases_c$date == as.Date("2021-05-21") & 
                                                                                                df_cases_c$type == "confirmed" &
                                                                                                df_cases_c$continent_name == "Europe")]) / 2
head(df_cases_c)
head(df)
