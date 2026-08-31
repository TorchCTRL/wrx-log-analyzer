# WRX Log Analyzer

WRX Log Analyzer is an iOS application built with Swift and SwiftUI for importing and analyzing Subaru WRX ECU log data.

It converts raw ROMRaider CSV logs into structured engine data, visualizations, and profile-aware analysis findings. Its goal is to make ECU logs easier to understand without modifying or flashing the vehicle's ECU.

## Why I Built It

ECU logs contain valuable information like engine speed, boost pressure, air-fuel ratio, knock corrections, and Dynamic Advance Multiplier (DAM), but raw CSV files can be difficult to interpret. WRX Log Analyzer provides a more approachable workflow for reviewing that data by:

- parsing ROMRaider CSV logs
- recognizing supported ECU measurements
- summarizing imported log quality
- calculating measurement statistics
- visualizing measurement data
- applying vehicle-specific analysis rules
- explaining findings in plain language
- linking analysis rules to supporting technical sources

## Core Features

- Import ROMRaider CSV log files
- Parse ECU measurements into structured Swift models
- Preserve unknown or missing measurements without rejecting the entire log
- Report malformed rows and parsing warnings
- View recognized measurements and log statistics
- Plot measurement values across the recorded log
- Configure vehicle, engine, tune, fuel, and driving context
- Persist the analysis profile across imports and app launches
- Select analysis rules based on profile compatibility
- Generate sourced analysis findings from supported measurements

## Current Analysis Support

The current rule catalog includes an EJ255 Dynamic Advance Multiplier (DAM) rule for supported Subaru WRX profiles. For a compatible profile, DAM values below `1.0` generate a caution finding rather than a diagnosis. The report includes:

- the observed value
- the configured threshold
- the CSV source line
- a plain-language explanation
- a link to the supporting technical source

The analysis system is intentionally conservative and does not claim to diagnose engine damage or vehicle safety.

## Technology

- Swift
- SwiftUI
- Swift Package Manager
- Swift Testing
- Charts
- UserDefaults
- Git and GitHub

## Architecture

The project is split into an iOS application and a reusable Swift package.

```text
ROMRaider CSV File
        ↓
   WRXLogCore
        ↓
CSV Parser
        ↓
EngineLog and Measurement Models
        ↓
Statistics / Log Insights
        ↓
Profile-Aware Analysis Rules
        ↓
   SwiftUI App
        ↓
Import Results / Analysis Report / Measurement Charts
```

### `WRXLogCore`

`WRXLogCore` contains the reusable domain and analysis logic, including ROMRaider CSV parsing, ECU measurement recognition, engine-log models, measurement statistics, log insights, analysis-profile compatibility, threshold-rule evaluation, and sourced WRX analysis rules.

Keeping this logic separate from the SwiftUI application allows the core functionality to be tested independently from the user interface.

### `WRXLogAnalyzer`

`WRXLogAnalyzer` is the iOS application and handles the user-facing workflow, including CSV importing, analysis-profile configuration and persistence, import summaries, warnings, analysis reports, and measurement charts.

## Example Analysis

A synthetic EJ255 DAM log is included in the test suite to exercise the analysis pipeline end to end.

For example, with the following compatible analysis profile:

```text
Model Year:        2013
Engine Family:     EJ255
Tune Type:         Stock
Fuel:              93 Octane
Driving Condition: Wide-Open Throttle
```

a recorded Dynamic Advance Multiplier value of `0.75` is evaluated against the configured DAM threshold of `1.0`.

The application generates a **Caution** finding that includes the observed value, rule threshold, CSV source line, a plain-language explanation, and a link to the supporting technical source.

```text
CSV Log
   ↓
ROMRaider Parser
   ↓
EngineLog
   ↓
DAM Measurement
   ↓
Profile Compatibility Check
   ↓
DAM Threshold Rule
   ↓
AnalysisFinding
   ↓
Analysis Report
```

The analysis is intentionally conservative and non-diagnostic. A low DAM value can have multiple causes, including ECU reset or reflash behavior, so the application presents the finding with context rather than claiming that engine damage has occurred.
