# Frozen series for measurement notes

## Official real GDP

World Bank, World Development Indicators, `NY.GDP.MKTP.KD` (GDP, constant 2015 US$).
Pulled 27 Aug 2026. Qatar 2015 = 161.74 billion; 2024 = 178.31 billion.
2025 exists in WDI (183.49 billion) but **is not used** in the lights comparison: the night-lights annual file stops at 2024.

PPP and market GDP per capita: `NY.GDP.PCAP.PP.KD` (constant 2017 international $) and `NY.GDP.PCAP.CD`.

File: `wdi_qat_ind.csv`.

## Night lights

World Bank, *Space2Stats Monthly & Annual Black Marble Nighttime Lights*, annual ADM2 file `ntl_adm2_annual.csv` (NASA Black Marble / VIIRS, aggregated to World Bank official boundaries). CC BY 4.0.

https://datacatalog.worldbank.org/search/dataset/0066940

Qatar rows extracted to `qatar_ntl_adm2.csv`; country totals in `qatar_ntl_annual.csv`.
`ntl_sum` = all lights. `ntl_sum_excl_flares_10km` drops lights within 10 km of World Bank flare locations.

Annual coverage in this extract: **2012–2024**. No 2025 annual composite in the file (last updated Dec 2025).

## Elasticity

Henderson, J. Vernon, Adam Storeygard, and David N. Weil. 2012. “Measuring Economic Growth from Outer Space.” *American Economic Review* 102 (2): 994–1028. Best-fit elasticity of measured **GDP growth with respect to lights growth** ≈ **0.3**.

Yao, Jiaxiong. 2019. “Illuminating Economic Growth.” *Finance & Development* (IMF). The assigned short reading. The notes **do** the Qatar calculation; they do not repeat the Canvas questions.

## Comparison window

**2015 vs 2024** (nine years). Same sensor family (VIIRS / Black Marble). Official real GDP and lights both observed.
