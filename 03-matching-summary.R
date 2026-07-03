# Quick summary of flight matching results

library(tidyverse)

# Load matched flights
matched <- read_csv("data/matched_flights.csv", show_col_types = FALSE)

cat("=" |> rep(70) |> paste(collapse = ""), "\n")
cat("FLIGHT MATCHING RESULTS SUMMARY\n")
cat("=" |> rep(70) |> paste(collapse = ""), "\n\n")

# Overall stats
cat(sprintf("Total matched flights: %d\n\n", nrow(matched)))

# Matching method breakdown
cat("Matching Method Breakdown:\n")
method_summary <- matched |>
  count(match_method) |>
  mutate(pct = round(100 * n / sum(n), 1))

print(method_summary, n = Inf)
cat("\n")

# Time difference statistics
cat("Time Difference Statistics (minutes):\n")
time_stats <- matched |>
  summarise(
    mean = round(mean(time_diff_min), 2),
    median = round(median(time_diff_min), 2),
    min = round(min(time_diff_min), 2),
    max = round(max(time_diff_min), 2),
    q95 = round(quantile(time_diff_min, 0.95), 2)
  )

print(time_stats)
cat("\n")

# Matches by route
cat("Matched Flights by Route:\n")
route_summary <- matched |>
  count(adep, ades) |>
  arrange(desc(n))

print(route_summary, n = Inf)
cat("\n")

# Brazil HFE v1 statistics
cat("Brazil HFE v1 Statistics (%):\n")
hfe_v1_stats <- matched |>
  summarise(
    mean = round(mean(bra_hfe_v1, na.rm = TRUE), 2),
    median = round(median(bra_hfe_v1, na.rm = TRUE), 2),
    min = round(min(bra_hfe_v1, na.rm = TRUE), 2),
    max = round(max(bra_hfe_v1, na.rm = TRUE), 2),
    sd = round(sd(bra_hfe_v1, na.rm = TRUE), 2)
  )

print(hfe_v1_stats)
cat("\n")

# Brazil HFE v2 statistics
cat("Brazil HFE v2 Statistics (%):\n")
hfe_v2_stats <- matched |>
  summarise(
    mean = round(mean(bra_hfe_v2, na.rm = TRUE), 2),
    median = round(median(bra_hfe_v2, na.rm = TRUE), 2),
    min = round(min(bra_hfe_v2, na.rm = TRUE), 2),
    max = round(max(bra_hfe_v2, na.rm = TRUE), 2),
    sd = round(sd(bra_hfe_v2, na.rm = TRUE), 2)
  )

print(hfe_v2_stats)
cat("\n")

# Aircraft types
cat("Aircraft Types in Matched Flights:\n")
equip_summary <- matched |>
  count(bra_equip, sort = TRUE) |>
  mutate(pct = round(100 * n / sum(n), 1))

print(equip_summary, n = 15)
cat("\n")

cat("=" |> rep(70) |> paste(collapse = ""), "\n")
