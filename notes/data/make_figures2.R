# Additional figures for measurement notes rewrite
suppressPackageStartupMessages({
  library(readr); library(dplyr); library(ggplot2)
})
root <- "/Users/andres/Academic/02_Teaching/73-103_Principles_of_Macro/2026_Fall/site/notes/data"
img  <- "/Users/andres/Academic/02_Teaching/73-103_Principles_of_Macro/2026_Fall/site/notes/img"
navy <- "#182C4B"; red <- "#C41230"; cream <- "#F7F4EE"; teal <- "#3D6B7A"

theme_notes <- function() {
  theme_minimal(base_size = 11) +
    theme(
      plot.background = element_rect(fill = cream, color = NA),
      panel.background = element_rect(fill = cream, color = NA),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#D9D2C6", linewidth = 0.3),
      text = element_text(color = navy),
      plot.title = element_text(face = "bold", size = 13),
      plot.subtitle = element_text(size = 9.5, color = "#5C6570"),
      plot.caption = element_text(size = 7.5, color = "#5C6570", hjust = 0),
      legend.position = "top", legend.title = element_blank()
    )
}

wdi <- read_csv(file.path(root, "wdi_qat_ind.csv"), show_col_types = FALSE)
nom <- wdi %>% filter(iso3=="QAT", indicator=="nominal_gdp_usd") %>% transmute(year, nominal = value)
re  <- wdi %>% filter(iso3=="QAT", indicator=="real_gdp_2015usd") %>% transmute(year, real = value)
q <- inner_join(nom, re, by="year") %>% filter(year>=2014, year<=2024) %>%
  mutate(nominal_idx = 100*nominal/nominal[year==2015],
         real_idx    = 100*real/real[year==2015])
long <- bind_rows(
  transmute(q, year, series="Nominal GDP (current US$)", index=nominal_idx),
  transmute(q, year, series="Real GDP (2015 US$)", index=real_idx)
)
p <- ggplot(long, aes(year, index, color=series)) +
  geom_hline(yintercept=100, color="#C9C1B2", linewidth=0.4) +
  geom_line(linewidth=1.05) + geom_point(size=2) +
  scale_color_manual(values=c("Nominal GDP (current US$)"=red, "Real GDP (2015 US$)"=navy)) +
  scale_x_continuous(breaks=2014:2024) +
  labs(title="Qatar: two stories, 2015 = 100",
       subtitle="Dollar GDP swings with energy prices. Real GDP (volume) does not.",
       x=NULL, y="Index",
       caption="WDI NY.GDP.MKTP.CD and NY.GDP.MKTP.KD. 2015 = 100.") +
  theme_notes() + theme(axis.text.x=element_text(angle=45,hjust=1))
ggsave(file.path(img,"qatar_nominal_real.png"), p, width=7.2, height=4.3, dpi=160)

# OWID scatters: latest year with decent coverage
life <- read_csv(file.path(root,"owid_life_gdp.csv"), show_col_types=FALSE) %>%
  rename(life = `Life expectancy at birth`, gdp = `GDP per capita`) %>%
  filter(!is.na(Code), nchar(Code)==3, !is.na(life), !is.na(gdp), Year==2022, Population > 1e6)
cm <- read_csv(file.path(root,"owid_childmort_gdp.csv"), show_col_types=FALSE) %>%
  rename(cm = `Child mortality rate`, gdp = `GDP per capita (int-$)`) %>%
  filter(!is.na(Code), nchar(Code)==3, !is.na(cm), !is.na(gdp), Year==2022)
el <- read_csv(file.path(root,"owid_electricity_gdp.csv"), show_col_types=FALSE) %>%
  rename(el = `Share with access to electricity`, gdp = `GDP per capita`) %>%
  filter(!is.na(Code), nchar(Code)==3, !is.na(el), !is.na(gdp), Year==2022)

hi <- c("QAT","USA","IND","CHN","KEN")
mark <- function(d) mutate(d, lab = ifelse(Code %in% hi, Entity, NA))

scatter <- function(d, y, ylab, title, caption, logy=FALSE) {
  d <- mark(d)
  g <- ggplot(d, aes(gdp, .data[[y]])) +
    geom_point(aes(color = !is.na(lab)), alpha=0.55, size=2.1, show.legend=FALSE) +
    scale_x_log10(labels=scales::label_number(scale_cut=scales::cut_short_scale())) +
    scale_color_manual(values=c("FALSE"="#8A9AA8", "TRUE"=red)) +
    ggrepel::geom_text_repel(aes(label=lab), size=3, color=navy, max.overlaps=20, min.segment.length=0) +
    labs(title=title, x="GDP per capita (log scale, int-$)", y=ylab, caption=caption) +
    theme_notes()
  if (logy) g <- g + scale_y_log10()
  g
}

# ggrepel may be missing
has_repel <- requireNamespace("ggrepel", quietly=TRUE)
lab_layer <- function() {
  if (has_repel) ggrepel::geom_text_repel(aes(label=lab), size=3, color=navy, max.overlaps=20, min.segment.length=0, na.rm=TRUE)
  else geom_text(aes(label=lab), size=3, color=navy, vjust=-0.8, na.rm=TRUE)
}

mk <- function(d, ycol, ylab, title, cap) {
  d <- mark(d)
  ggplot(d, aes(gdp, .data[[ycol]])) +
    geom_point(color="#8A9AA8", alpha=0.5, size=2) +
    geom_point(data=filter(d, Code %in% hi), color=red, size=2.6) +
    lab_layer() +
    scale_x_log10(labels=scales::label_number(accuracy=1, scale_cut=scales::cut_short_scale())) +
    labs(title=title, x="GDP per capita (international-$, log)", y=ylab, caption=cap) +
    theme_notes()
}

p1 <- mk(life, "life", "Life expectancy at birth (years)",
         "Richer countries live longer — 2022",
         "Our World in Data: life expectancy vs GDP per capita. Highlighted: Qatar, US, China, India, Kenya.")
p2 <- mk(cm, "cm", "Child deaths per 1,000 live births",
         "Child mortality falls as income rises — 2022",
         "Our World in Data: child mortality vs GDP per capita.")
p3 <- mk(el, "el", "Share with electricity access (%)",
         "Electricity access and GDP per capita — 2022",
         "Our World in Data: access to electricity vs GDP per capita.")
ggsave(file.path(img,"owid_life.png"), p1, width=7.0, height=4.5, dpi=160)
ggsave(file.path(img,"owid_childmort.png"), p2, width=7.0, height=4.5, dpi=160)
ggsave(file.path(img,"owid_electricity.png"), p3, width=7.0, height=4.5, dpi=160)
message("ok")
