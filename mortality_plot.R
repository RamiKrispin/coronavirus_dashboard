coronavirus::update_dataset()
# reset the session
library(coronavirus)
data("coronavirus")
max(coronavirus$date)
head(coronavirus)
table(coronavirus$continent_name, useNA = "always")
table(coronavirus$province, useNA = "always")
df <- coronavirus %>% 
  dplyr::filter(!is.na(continent_code),
                is.na(province)) 

head(df)






df <- coronavirus::refresh_coronavirus_jhu()
max(df$date)

head(df)
head(df_cases)
unique(df_cases$province)
table(df_cases$province, useNA = "always")
unique(df_cases$country)

df <- df_cases %>% dplyr::filter(is.na(province),
                                 type != "recovery") %>%
  dplyr::select(date, country, type, cases, population) %>%
  tidyr::pivot_wider(names_from = type, values_from = cases)
head(df)
tail(df)

df_agg <- df %>% 
  dplyr::group_by(country) %>%
  dplyr::summarise(confirmed = sum(confirmed),
                   death = sum(death)) %>%
  dplyr::arrange(- death) %>%
  dplyr::left_join(df %>% 
                     dplyr::select(country, population) %>% 
                     dplyr::distinct(),
                   by = "country") %>%
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
                      text = paste(df_rest$country, "<br>",
                                   round(100 * df_rest$death / df_rest$confirmed, 1) , "%",
                                   sep = ""),
                      marker = list(color = "orange"),
                      showlegend = FALSE) %>%
  plotly::add_markers(x = df_top20$confirmed,
                      y = df_top20$death,
                      hoverinfo = "text",
                      text = paste(df_top20$country, "<br>",
                                   round(100 * df_top20$death / df_top20$confirmed, 1) , "%",
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




library(pracma)
library(plotly)

x = linspace(1, 200, 30)
data.frame(x = x, y = x**3)
fig <- plot_ly(x = x, y = x**3, type = 'scatter', mode = 'markers') %>%
  layout(xaxis = list(range = c(log10(0.8), log10(250)),
                      type = 'log',
                      zerolinecolor = '#ffff',
                      zerolinewidth = 2,
                      gridcolor = 'ffff',
                      title = 'x'),
         yaxis = list(type = 'log',
                      zerolinecolor = '#ffff',
                      zerolinewidth = 2,
                      gridcolor = 'ffff',
                      title = 'y'),
         plot_bgcolor='#e5ecf6')

fig
