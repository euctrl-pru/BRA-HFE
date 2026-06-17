# BRA-HFE: Brazil Horizontal Flight Efficiency Analysis

Analysis of Brazilian radar surveillance data for Horizontal Flight Efficiency (HFE) validation.

## Project Overview

This project analyzes Brazilian radar surveillance data to:
- Extract and process flight trajectories from radar position reports
- Calculate HFE indicators using 40 NM and 100 NM milestone methodology
- Validate calculations against Brazilian reference HFE data
- Develop reproducible analytical workflows for ongoing HFE analysis

## Project Structure

```
BRA-HFE/
├── R/
│   └── sf_helpers.R           # Spatial geometry utility functions
├── data/
│   ├── sample_trajectories_2025_12_10.parquet   # Extracted trajectories
│   ├── flight_summary.csv                       # Movement summary
│   └── brazil_hfe_2025_12_10.csv               # Brazil HFE reference
├── 01-data-exploration.qmd    # Main analysis document
└── README.md
```

## Data Sources

### Radar Surveillance Data
- **File**: `radar_2025_12_10.csv` (8.8M position reports, 2025-12-10)
- **Source**: Brazilian surveillance system
- **Location**: `../radar_brazil/data-raw/` (companion repository)

### Brazil HFE Reference Data
- **File**: `BRA-KEA-2025.csv` (268K flights, full year 2025)
- **Source**: Brazilian HFE calculations
- **Location**: `../radar_brazil/data-raw/`

### Airport Reference Data
- **File**: `brazil_airports_arp.csv` (2,878 aerodromes)
- **Source**: OurAirports database
- **Location**: `../radar_brazil/data-raw/`

## Analysis Workflow

### 1. Data Extraction
Target aerodrome pairs (bidirectional):
- SBCF ↔ SBKP
- SBCF ↔ SBSP
- SBBR ↔ SBCT
- SBBR ↔ SBSV
- SBGR ↔ SBSV
- SBGR ↔ SBRJ

**Result**: 127 flights extracted for 2025-12-10

### 2. Trajectory Segmentation
- Temporal gap detection (>30 min)
- Callsign change detection
- ADEP/ADES consistency filtering
- Airport reference point enrichment

### 3. Milestone Extraction
Milestone points per trajectory:
- **FIRST_HIT**: First surveillance point (takeoff proxy)
- **40NM_ADEP**: First crossing 40 NM from departure ARP
- **40NM_ADES**: Last crossing 40 NM to arrival ARP
- **100NM_ADEP**: First crossing 100 NM from departure ARP
- **100NM_ADES**: Last crossing 100 NM to arrival ARP
- **LAST_HIT**: Last surveillance point (landing proxy)

### 4. HFE Calculation
```
HFE = (Achieved Distance / Flown Distance) × 100%

where:
- Achieved Distance = Great circle distance between milestones
- Flown Distance = Cumulative trajectory distance between milestones
```

## Dependencies

### R Packages
- `tidyverse` - Data manipulation and visualization
- `arrow` - Parquet file handling
- `sf` - Spatial geometry operations
- `units` - Unit conversions
- `trrrj` - Trajectory analysis utilities ([euctrl-pru/trrrj](https://github.com/euctrl-pru/trrrj))

### Companion Repositories
- [radar_brazil](https://github.com/euctrl-pru/radar_brazil) - Radar data processing utilities
- [pbwgtrajectory](https://github.com/euctrl-pru/pbwgtrajectory) - Trajectory helper functions

## Usage

### Render Analysis Document
```r
quarto render 01-data-exploration.qmd
```

### Load Extracted Trajectories
```r
library(arrow)
df <- read_parquet("data/sample_trajectories_2025_12_10.parquet")
```

### Use Spatial Helpers
```r
source("R/sf_helpers.R")

# Convert lat/lon to sf points
pts_sf <- cast_latlon_to_pts(df, 
  lon_col = "longitude", 
  lat_col = "latitude")

# Convert to linestrings grouped by flight
ls_sf <- cast_pts_to_ls(pts_sf, .group_var = fid)
```

## Key Findings (Preliminary)

- **Total flights extracted**: 127 (12 route pairs)
- **Busiest route**: SBCF → SBSP (30 flights)
- **HFE methodology**: 40 NM and 100 NM milestone pairs
- **Next steps**: Validate against Brazil HFE reference data

## References

- [ANS Performance Framework - HFE Methodology](https://ansperformance.eu/methodology/horizontal-flight-efficiency-pi/)
- ICAO Doc 030 - Global Air Navigation Plan

## Contact

PRU Analysis Team - EUROCONTROL

## License

[Add license information]
