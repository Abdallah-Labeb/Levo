# Levo — Professional Measurement Toolkit
> **Tagline**: Level Everything
> **Version Target**: 1.0.0
> **Platform**: Android (minSdk 23, Android 6.0+) — iOS planned via same Flutter codebase
> **Framework**: Flutter 3.19+ / Dart 3.3+

---

## The Concept

**Levo** is a professional-grade, 100% offline measurement toolkit that bundles 10 physical-tool equivalents into a single app. The name comes from "Level" — representing the app's core mission of bringing precision and accuracy to every measurement task.

The defining identity of this app is its **Industrial Skeuomorphic UI**. While every competitor ships flat Material Design screens, Levo renders each tool to look and feel like the real physical instrument it replaces: glass bubble levels with fluid and a floating bubble, chrome compass bezels with engraved markings, analog VU meters with swinging needles, rulers with stamped tick marks on metal or wood surfaces. The app should feel like opening a professional tool bag, not launching another utility app.

---

## Core Principles

### 1. Local-First, Always
- 100% offline. Zero network requests at runtime.
- No accounts, no sign-ups, no user data collected.
- No Firebase, no Analytics, no crash reporters that phone home.
- All state lives in SharedPreferences and Hive on-device.

### 2. Performance-First
- Release APK target: **≤ 30 MB** (with R8 + Dart tree-shaking + `--split-per-abi`)
- Cold start target: **≤ 800ms** on a Snapdragon 665-class device
- Animations: **60fps minimum** on all supported hardware
- Sensor subscribers cancelled in `dispose()` — no background polling when tool is not visible
- Battery: use `SensorInterval.ui` sampling rate (not `game`), never `SensorInterval.fastest`

### 3. Authentic Industrial Feel
- Every tool screen is a purpose-built custom widget — no generic cards or list tiles for tool content
- Skeuomorphic materials: brushed metal, glass, rubber, engraved markings, chrome bezels
- Bubble level uses spring physics for realistic fluid simulation
- Haptic and audio feedback mirrors real tool behavior
- No placeholder illustrations — every widget is the functional tool

### 4. Honest Precision
- Proper sensor calibration flows for Spirit Level and Ruler
- Low-pass filtering with user-adjustable viscosity
- Accuracy/confidence indicators shown when sensor reliability is low
- No fake precision (e.g., no artificially small decimal places on uncalibrated data)

---

## Business Model

### Free Tier
- All 10 tools fully functional — no feature gates
- Adaptive banner ad at the bottom of every tool screen
- Interstitial ad shown on return to Home screen, **max once per 10 minutes**
- No mid-measurement interruptions, no pop-ups, no rewarded ads

### Pro Tier — One-Time Purchase ($2.99)
- Removes all ads permanently
- Implemented via `in_app_purchase` package
- Status stored locally (`SharedPreferences` key: `levo_prem_status`)
- No server-side validation required at this price point

---

## Tool Roster (All 10 in v1.0.0)

| # | Tool Name | Primary Sensor | One-Line Description |
|---|-----------|----------------|----------------------|
| 1 | Spirit Level | Accelerometer | 2D/1D bubble level + Plumb Bob |
| 2 | Digital Ruler | Screen (calibrated PPI) | Screen-based physical ruler |
| 3 | Compass | Magnetometer + optional GPS | Magnetic & true-north compass |
| 4 | Protractor | Touch screen | Touch-draw angle measurement |
| 5 | Sound Level Meter | Microphone | Real-time dB SPL meter |
| 6 | Vibration Meter | Accelerometer | Seismograph-style vibration display |
| 7 | Light Meter | Ambient sensor / Camera | Lux + EV measurement |
| 8 | Metal Detector | Magnetometer | Magnetic field proximity detector |
| 9 | Unit Converter | None (pure math) | Construction unit converter |
| 10 | Clinometer | Accelerometer | Slope angle and percentage grade |

---

## Target Users

| Audience | Primary Use |
|----------|-------------|
| Construction workers & contractors | Daily job-site leveling, angle checks |
| Carpenters, tilers, plumbers | Precision cuts, pipe slopes, alignment |
| Electricians | Panel alignment, conduit angles |
| DIY homeowners | Hanging shelves, furniture assembly, tiling |
| Engineers & architects | Quick field verification |
| Hobbyists & workshop makers | Workbench measurements |

---

## Language Support

- **English** — primary
- **Arabic** — full RTL support from v1.0.0 (use `flutter_localizations`, all strings in ARB files)

---

## Explicit Non-Goals for v1.0.0

These features must NOT be built in v1. They are documented to prevent scope creep:

- No camera-based AR measurement (ARCore)
- No cloud sync or backup
- No social features or measurement sharing
- No user accounts or profiles
- No AI or ML features
- No iOS build or submission (same codebase, but Android-only store release)
- No paid Pro subscription tier (one-time purchase only)
- No backend of any kind

---

## Competitive Positioning

| Feature | Levo | iHandy Level | Bubble Level | AR Ruler |
|---------|:-------:|:------------:|:------------:|:--------:|
| Industrial skeuomorphic UI | ✅ Full | ✅ Partial | ❌ Flat | ❌ Flat |
| 10 tools in one app | ✅ | ❌ 1 tool | ❌ 1 tool | ❌ 1 tool |
| 100% offline | ✅ | ✅ | ✅ | ❌ |
| Arabic + RTL support | ✅ | ❌ | ❌ | ❌ |
| Advanced sensor calibration | ✅ | ✅ Basic | ❌ | ❌ |
| Adjustable noise filtering | ✅ | ❌ | ❌ | ❌ |
| Open, auditable code | ✅ | ❌ | ❌ | ❌ |
| Free with ethical ads | ✅ | ❌ Paid | ✅ | ❌ Paid |
