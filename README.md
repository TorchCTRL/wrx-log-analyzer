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
- Apple Charts
- UserDefaults
- Git and GitHub
