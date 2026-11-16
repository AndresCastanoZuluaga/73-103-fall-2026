# Measurement-notes figures. Frozen CSVs in this folder.
suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(ggplot2)
})

root <- if (sys.nframe() == 0L) getwd() else dirname(sys.frame(1)$ofile)
# when sourced from notes/data
if (!file.exists(file.path(root, "qatar_ntl_annual.csv"))) {
  root <- "/Users/andres/Academic/02_Teaching/73-103_Principles_of_Macro/2026_Fall/site/notes/data"
}
img <- file.path(dirname(root), "img")
dir.create(img, showWarnings = FALSE)

navy <- "#182C4B"
red  <- "#C41230"
teal <- "#3D6B7A"
cream <- "#F7F4EE"

theme_notes <- function() {
  theme_minimal(base_size = 12, base_family = "sans") +
    theme(
      plot.background = element_rect(fill = cream, color = NA),
      panel.background = element_rect(fill = cream, color = NA),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#D9D2C6", linewidth = 0.3),
      text = element_text(color = navy),
      plot.title = element_text(face = "bold", size = 13),
      plot.subtitle = element_text(size = 10, color = "#5C6570"),
      plot.caption = element_text(size = 8, color = "#5C6570", hjust = 0),
      legend.position = "top",
      legend.title = element_blank()
    )
}

ntl <- read_csv(file.path(root, "qatar_ntl_annual.csv"), show_col_types = FALSE)
wdi <- read_csv(file.path(root, "wdi_qat_ind.csv"), show_col_types = FALSE)

gdp <- wdi %>%
  filter(iso3 == "QAT", indicator == "real_gdp_2015usd") %>%
  transmute(year, real_gdp = value)

panel <- ntl %>%
  inner_join(gdp, by = "year") %>%
  filter(year >= 2012, year <= 2024) %>%
  mutate(
    lights_idx = 100 * ntl_sum / ntl_sum[year == 2015],
    gdp_idx    = 100 * real_gdp / real_gdp[year == 2015]
  )

long <- bind_rows(
  transmute(panel, year, series = "Night lights (Black Marble)", index = lights_idx),
  transmute(panel, year, series = "Official real GDP", index = gdp_idx)
)

p1 <- ggplot(long, aes(year, index, color = series)) +
  geom_hline(yintercept = 100, color = "#C9C1B2", linewidth = 0.4) +
  geom_line(linewidth = 1.05) +
  geom_point(size = 2.1) +
  scale_color_manual(values = c("Night lights (Black Marble)" = red,
                                "Official real GDP" = navy)) +
  scale_x_continuous(breaks = 2012:2024) +
  labs(
    title = "Qatar: lights and the books, 2015 = 100",
    subtitle = "Sum of VIIRS/Black Marble radiance vs real GDP (constant 2015 US$)",
    x = NULL, y = "Index",
    caption = "Lights: World Bank Space2Stats / NASA Black Marble. GDP: WDI NY.GDP.MKTP.KD."
  ) +
  theme_notes() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(file.path(img, "qatar_lights_vs_gdp.png"), p1, width = 7.2, height = 4.4, dpi = 160)

pc <- wdi %>%
  filter(year == 2024, indicator %in% c("gdppc_current_usd", "gdppc_ppp_2017int")) %>%
  mutate(
    country = recode(iso3, QAT = "Qatar", IND = "India"),
    measure = recode(indicator,
                     gdppc_current_usd = "Market dollars",
                     gdppc_ppp_2017int = "PPP dollars")
  )

p2 <- ggplot(pc, aes(country, value / 1000, fill = measure)) +
  geom_col(position = position_dodge(width = 0.72), width = 0.68) +
  scale_fill_manual(values = c("Market dollars" = navy, "PPP dollars" = red)) +
  labs(
    title = "GDP per person, 2024",
    subtitle = "Market US$ vs constant 2017 international $ (PPP)",
    x = NULL, y = "Thousands",
    caption = "WDI NY.GDP.PCAP.CD and NY.GDP.PCAP.PP.KD."
  ) +
  theme_notes()
ggsave(file.path(img, "qatar_india_ppp_2024.png"), p2, width = 6.4, height = 4.2, dpi = 160)

message("wrote ", file.path(img, "qatar_lights_vs_gdp.png"))
message("wrote ", file.path(img, "qatar_india_ppp_2024.png"))
