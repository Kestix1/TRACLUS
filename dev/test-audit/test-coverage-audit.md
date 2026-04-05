# TRACLUS Test Coverage Audit

<!-- Phase 1: Zeilenstruktur aufgebaut 2026-04-02 -->
<!-- Phase 2: Matrix füllen — abgeschlossen 2026-04-02 -->
<!-- Phase 3: Synthese — abgeschlossen 2026-04-02 -->

## Status

| Phase | Status | Session | Offene Testdateien |
|-------|--------|---------|-------------------|
| 1: Zeilenstruktur | ✓ erledigt | 2026-04-02 | — |
| 2: Matrix füllen | ✓ erledigt | 2026-04-02 | — |
| 3: Synthese | ✓ erledigt | 2026-04-02 | — |
| 4: CRITICAL+HIGH Tests schreiben | ✓ erledigt | 2026-04-05 | — |
| 5: MEDIUM+LOW Tests + Redundanzbereinigung | ✓ erledigt | 2026-04-06 | — |

**Session 1 (2026-04-05):** 16 neue `test_that()`-Blöcke für alle CRITICAL+HIGH-Lücken implementiert (C-1..C-4, H-1..H-12). `devtools::test()`: FAIL 0 | WARN 6 | SKIP 0 | PASS 1057.

**Session 2 (2026-04-06):** 11 neue `test_that()`-Blöcke für alle MEDIUM+LOW-Lücken (M-1..M-7, L-1..L-3). Redundanzbereinigung: 17 `test_that()`-Blöcke aus R1–R5 entfernt (tprs ×7, thlp ×3, twfl ×3, ttrc ×4). `devtools::test()` Abschluss: FAIL 0 | WARN 4 | SKIP 0 | PASS 1041.

---

## Spaltenlegende

| Kürzel | Datei |
|--------|-------|
| tdis | test-distances.R |
| tsph | test-distances-spherical.R |
| tcpp | test-distances-cpp.R |
| thlp | test-helpers.R |
| tprt | test-tc_partition.R |
| tclst | test-tc_cluster.R |
| trpr | test-tc_represent.R |
| test | test-tc_estimate_params.R |
| ttrj | test-tc_trajectories.R |
| ttrc | test-tc_traclus.R |
| tedg | test-edge-cases.R |
| tgld | test-golden-scenarios.R |
| twfl | test-workflow-integration.R |
| tplt | test-plot.R |
| tprs | test-print-summary.R |
| thrd | test-tc_read_hurdat2.R |

### Zellenwerte
- `✓` — explizit getestet
- `⚠` — indirekt/implizit gedeckt
- `✗` — keine Abdeckung
- `♻` — redundant (bereits durch eine andere Spalte dieser Zeile abgedeckt)

---

## Coverage Matrix

### A — Distanzfunktionen Euklidisch

| # | Verhalten | Quelle | tdis | tsph | tcpp | thlp | tprt | tclst | trpr | test | ttrj | ttrc | tedg | tgld | twfl | tplt | tprs | thrd |
|---|-----------|--------|------|------|------|------|------|-------|------|------|------|------|------|------|------|------|------|------|
| A01 | d_perp: Nicht-Negativität (>= 0 immer) | Paper Def.1+Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| A02 | d_perp: Symmetrie d(i,j) = d(j,i) | Paper Def.1+Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| A03 | d_perp: Identische Segmente → 0 | Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| A04 | d_perp: Parallel-versetzt (beide Punkte gleiche Distanz) | Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| A05 | d_perp: Kollinear (gleiche Linie) → d_perp ≈ 0 | Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A06 | d_perp: Lehmer-Mittel (l1²+l2²)/(l1+l2) korrekt berechnet | Paper Def.1+Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| A07 | d_perp: Swap-Konvention — längeres Segment wird Li | Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| A08 | d_perp: Tie-Breaking bei exakt gleicher Länge → erstes bleibt Li | Code | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A09 | d_perp: Null-Länge Segment (len < 1e-15) → 0 | Code | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A10 | d_perp: Beide Projektionen auf Li = 0 (l1=l2=0) → 0 | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A11 | d_par: Nicht-Negativität (>= 0 immer) | Paper Def.2+Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| A12 | d_par: Symmetrie d(i,j) = d(j,i) | Paper Def.2+Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| A13 | d_par: Vollständig überlappende Segmente → 0 | Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| A14 | d_par: Nicht-überlappend nebeneinander → > 0 | Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A15 | d_par: MIN-Operator min(l_par1, l_par2) korrekt | Paper Def.2+Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| A16 | d_par: t-Parameter < 0 oder > 1 möglich (Projektion auf Linie, nicht Segment) | Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A17 | d_par: Swap-Konvention | Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| A18 | d_angle: Nicht-Negativität (>= 0 immer) | Paper Def.3+Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| A19 | d_angle: Symmetrie d(i,j) = d(j,i) | Paper Def.3+Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| A20 | d_angle: θ=0° (parallele Segmente) → 0 | Paper Def.3+Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| A21 | d_angle: θ=90° (Grenzfall Piecewise) → len_j | Paper Def.3 | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A22 | d_angle: θ>90° (stumpfes Segment) → len_j | Paper Def.3+Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| A23 | d_angle: θ<90° (spitzes Segment) → len_j * sin(θ) | Paper Def.3+Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A24 | d_angle: cos_theta geklemmt auf [-1,1] vor acos (Floating-Point-Safety) | Code | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A25 | d_angle: Null-Länge Lj (len_j < 1e-15) → 0 | Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A26 | d_angle: Null-Länge Li (len_i < 1e-15) → len_j | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A27 | d_angle: Swap-Konvention | Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| A28 | Input-Validierung: si, ei, sj, ej numeric length-2 | Code | ✓ | ✗ | ✗ | ♻ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A29 | Input-Validierung: alle Koordinaten finite (kein NA/NaN/Inf) | Code | ✓ | ✗ | ✗ | ♻ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A30 | Gewichte-Validierung: w_perp >= 0, finite, single numeric | Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A31 | Gewichte-Validierung: w_par >= 0, finite, single numeric | Code | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A32 | Gewichte-Validierung: w_angle >= 0, finite, single numeric | Code | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A33 | Alle Gewichte = 0 → dist = 0 für alle Paare (degeneriert) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A34 | tc_dist_segments: gewichtete Summe korrekt | Paper 2.3+Code | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| A35 | tc_dist_segments: method='euclidean' wird akzeptiert | Code | ✓ | ✗ | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| A36 | tc_dist_segments: method='haversine' wird akzeptiert | Code | ✗ | ✓ | ✗ | ✗ | ⚠ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A37 | tc_dist_segments: Ungültiger method → Error | Code | ✓ | ✗ | ✗ | ♻ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| A38 | Distanz-Dreiecksungleichung kann verletzt werden (keine Metrik) | Paper Remark | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

### B — Distanzfunktionen Sphärisch (Haversine)

| # | Verhalten | Quelle | tdis | tsph | tcpp | thlp | tprt | tclst | trpr | test | ttrj | ttrc | tedg | tgld | twfl | tplt | tprs | thrd |
|---|-----------|--------|------|------|------|------|------|-------|------|------|------|------|------|------|------|------|------|------|
| B01 | Haversine: Nicht-Negativität (>= 0 immer) | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B02 | Haversine: Symmetrie d(p1,p2) = d(p2,p1) | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B03 | Haversine: Identische Punkte → 0 | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ♻ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B04 | Haversine: Antipodal (nahe π×R ≈ 20015 km) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B05 | Haversine: a auf [0,1] geklemmt vor asin (numerische Sicherheit) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B06 | Bearing: Normalisierung auf [0, 360) | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B07 | Bearing: 0° (Nord), 90° (Ost), 180° (Süd), 270° (West) | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B08 | Bearing: Identische Punkte (undefined) → kein Crash | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B09 | Cross-track: Nicht-Negativität (Absolutwert) | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B10 | Cross-track: Punkt auf Great Circle → 0 | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B11 | Cross-track: sin_xt auf [-1,1] geklemmt vor asin | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B12 | Along-track signed: Positiver Wert (in Richtung A→B) | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B13 | Along-track signed: Negativer Wert (hinter A) | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B14 | Along-track signed: cos_xt < 1e-15 → 0 (Schutz vor Division) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B15 | d_perp_sph: Lehmer-Mittel aus Cross-Track-Distanzen | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B16 | d_perp_sph: Swap-Konvention (Haversine-Länge) | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B17 | d_par_sph: Signed Along-Track für Projektion | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B18 | d_par_sph: min(abs(at), abs(at - len_i)) pro Punkt | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B19 | d_par_sph: Swap-Konvention | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B20 | d_angle_sph: Bearing-Differenz auf [0°, 180°] normalisiert | Code | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B21 | d_angle_sph: θ < 90° → len_j * sin(θ_rad) | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B22 | d_angle_sph: θ >= 90° → len_j | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B23 | d_angle_sph: Null-Länge Lj → 0 | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B24 | d_angle_sph: Null-Länge Li → len_j | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B25 | d_angle_sph: Swap-Konvention | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B26 | Haversine-Koordinaten: Latitude außerhalb [-90,90] → warning | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B27 | Haversine-Koordinaten: Longitude außerhalb [-180,180] → warning | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B28 | d_perp_sph: Symmetrie | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| B29 | d_par_sph: Symmetrie | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

### C — C++-Konsistenz & Early Termination

| # | Verhalten | Quelle | tdis | tsph | tcpp | thlp | tprt | tclst | trpr | test | ttrj | ttrc | tedg | tgld | twfl | tplt | tprs | thrd |
|---|-----------|--------|------|------|------|------|------|-------|------|------|------|------|------|------|------|------|------|------|
| C01 | C++ vs R d_perp_euc: numerische Konsistenz (tol ~1e-10) | Code | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| C02 | C++ vs R d_par_euc: numerische Konsistenz (tol ~1e-10) | Code | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| C03 | C++ vs R d_angle_euc: numerische Konsistenz (tol ~1e-10) | Code | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| C04 | C++ vs R d_perp_sph: numerische Konsistenz (tol ~1e-10) | Code | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| C05 | C++ vs R d_par_sph: numerische Konsistenz (tol ~1e-10) | Code | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| C06 | C++ vs R d_angle_sph: numerische Konsistenz (tol ~1e-10) | Code | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| C07 | Early Termination: accumulated > eps nach d_perp → return (d_par, d_angle skipped) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| C08 | Early Termination: accumulated > eps nach d_par → return (d_angle skipped) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| C09 | Early Termination: Rückgabewert >= echter Distanz (Partial >= Full) | Code | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| C10 | Early Termination: w_perp=0 → d_perp wird nicht berechnet | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| C11 | Early Termination: w_par=0 → d_par wird nicht berechnet | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| C12 | Early Termination: w_angle=0 → d_angle wird nicht berechnet | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| C13 | Early Termination (sph): analoges Verhalten wie euc | Code | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| C14 | Haversine vs Bearing vs Cross-track: C++ vs R alle konsistent | Code | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| C15 | Tie-Breaking: exakt gleiche Längen → erstes bleibt Li (C++ und R identisch) | Code | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| C16 | Traclus weighted dist (euc+sph): korrekte Gesamtsumme wenn kein Early Exit | Code | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

### D — Input-Validierung & Preprocessing

| # | Verhalten | Quelle | tdis | tsph | tcpp | thlp | tprt | tclst | trpr | test | ttrj | ttrc | tedg | tgld | twfl | tplt | tprs | thrd |
|---|-----------|--------|------|------|------|------|------|-------|------|------|------|------|------|------|------|------|------|------|
| D01 | Fehlender x-Parameter → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D02 | Fehlender y-Parameter → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D03 | Fehlender coord_type → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D04 | coord_type ungültig (nicht euclidean/geographic) → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D05 | x-Spalte nicht in Daten → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D06 | y-Spalte nicht in Daten → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D07 | traj_id-Spalte nicht in Daten → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D08 | x-Spalte nicht numerisch → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D09 | y-Spalte nicht numerisch → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D10 | data nicht data.frame/tibble/sf → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D11 | coord_type='euclidean' + method='haversine' → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D12 | coord_type='euclidean' + method='projected' → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D13 | coord_type='geographic' + method=NULL → default='haversine' | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D14 | coord_type='geographic' + method='projected' → akzeptiert | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D15 | coord_type='geographic' + method='euclidean' → message+akzeptiert | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D16 | sf-Objekt ohne CRS → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D17 | sf-Objekt mit POINT-Geometrie → Koordinaten extrahiert | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D18 | sf-Objekt mit Z/M-Dimensionen → message, nur X,Y verwendet | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D19 | sf-Objekt mit nicht-POINT-Geometrie → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D20 | NA in x oder y → Zeilen entfernt, warning | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D21 | Inf in x oder y → Zeilen entfernt, warning | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D22 | NaN in x oder y → Zeilen entfernt, warning | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D23 | Aufeinanderfolgende doppelte Punkte (selbe traj_id, x, y) → entfernt | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ♻ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D24 | Nicht-aufeinanderfolgende Duplikate → nicht entfernt | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D25 | Trajektorie mit 1 Punkt nach Filterung → entfernt, warning | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ♻ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D26 | Nach gesamter Filterung < 2 Trajektorien → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ⚠ | ✓ | ✗ | ✗ | ✗ | ✗ |
| D27 | traj_id numeric → zu character konvertiert | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D28 | traj_id factor → zu character konvertiert | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D29 | geographic + x außerhalb [-180,180] → warning | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D30 | geographic + y außerhalb [-90,90] → warning | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D31 | geographic + vertauschte Koordinaten (x in lat-Bereich) → warning | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D32 | geographic + Antimeridian-Crossing (|Δx| > 180°) → warning | Code | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ♻ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D33 | Antimeridian-Crossing nur innerhalb Trajektorie erkannt (nicht zwischen Trajs) | Code | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D34 | euclidean + looks like lon/lat → warning | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D35 | method='projected' → proj_params (lat_mean, lon_mean) gespeichert | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| D36 | Eingabe ungeordnet → nach traj_id gruppiert, Punktreihenfolge erhalten | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D37 | NA in traj_id → Zeile entfernt | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D38 | Verbose=TRUE → informative Meldungen | Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D39 | Falsche Input-Klasse für tc_partition (non-tc_trajectories) → Error | Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| D40 | .truncate_ids: Viele IDs korrekt abgeschnitten ("and N more") | Code | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ♻ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

### E — Partitionierungsphase (MDL)

| # | Verhalten | Quelle | tdis | tsph | tcpp | thlp | tprt | tclst | trpr | test | ttrj | ttrc | tedg | tgld | twfl | tplt | tprs | thrd |
|---|-----------|--------|------|------|------|------|------|-------|------|------|------|------|------|------|------|------|------|------|
| E01 | Gerade 2-Punkt-Trajektorie → genau 1 Segment | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| E02 | Gerade viele-Punkt-Trajektorie → genau 1 Segment (kein Split) | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| E03 | L-förmige Trajektorie → Split am Knick, genau 2 Segmente | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| E04 | MDL costnopar: korrekte Berechnung (log2 der Segmentlänge) | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| E05 | MDL costpar: korrekte Berechnung (d_perp + d_angle, kein d_par) | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| E06 | MDL: d_par wird NICHT in der Kostenfunktion verwendet | Paper | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| E07 | MDL Bias-Term: verhindert Over-Partitioning bei kurzen Segmenten | Paper Sec.4.1.3 | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| E08 | Zero-Length-Segment nach Partitionierung → entfernt, warning | Code | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| E09 | Alle Segmente zero-length → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| E10 | method='projected': Vorwärts-Projektion vor Partitionierung | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ♻ | ✗ | ✗ | ✗ |
| E11 | method='projected': Rückwärts-Projektion der Endpunkte | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ♻ | ✗ | ✗ | ✗ |
| E12 | method='haversine': keine Projektion | Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| E13 | Aufeinanderfolgende Segmente verbunden (end_i = start_{i+1}) | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| E14 | Segment-IDs sequenziell pro Trajektorie (1, 2, 3, ...) | Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| E15 | .equirectangular_proj: korrekte Formel (lon * cos(lat_mean) * 111320) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| E16 | .equirectangular_inverse: Proj und Inverse sind tatsächlich invers | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| E17 | costpar > costnopar an Knickpunkt → Partition gesetzt | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| E18 | costpar <= costnopar bei geraden Strecken → kein Split | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| E19 | Haversine-Methode: Partitionierung in geografischen Koordinaten | Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ♻ | ✗ | ✗ | ✗ |
| E20 | n_segments-Anzahl im Ergebnisobjekt korrekt | Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

### F — Clustering-Phase (DBSCAN)

| # | Verhalten | Quelle | tdis | tsph | tcpp | thlp | tprt | tclst | trpr | test | ttrj | ttrc | tedg | tgld | twfl | tplt | tprs | thrd |
|---|-----------|--------|------|------|------|------|------|-------|------|------|------|------|------|------|------|------|------|------|
| F01 | Core Segment: |N_ε(L)| >= min_lns (Self-Inclusive: +1 Offset) | Paper Def.5+Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| F02 | Non-Core Segment: |N_ε(L)| < min_lns → initial Noise | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| F03 | BFS Expansion: unclassified Segment → assigned + enqueued | Paper Fig.12+Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| F04 | Noise Absorption: Noise-Segment → assigned zu Cluster ABER nicht enqueued | Paper Fig.12 Ln23-26 | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| F05 | Already-clustered Segment: nicht re-assigned | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| F06 | Trajectory Cardinality: Cluster < min_lns Trajektorien → degradiert zu Noise | Paper Def.10+Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| F07 | Trajectory Cardinality: Cluster = min_lns Trajektorien → bleibt Cluster | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| F08 | Cluster-Renumbering nach Cardinality-Filterung (sequenziell 1..K) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| F09 | Alle Segmente Noise (0 Cluster) → warning | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| F10 | eps sehr klein → alle Noise | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| F11 | eps sehr groß → ein großer Cluster | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| F12 | min_lns = 1 → Verhalten (jedes Segment Core) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| F13 | Alle Gewichte = 0 → dist = 0 für alle Paare (degenerierter Fall) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| F14 | eps <= 0 → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| F15 | min_lns < 1 → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| F16 | Negative Gewichte → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| F17 | method='projected': Koordinaten vor Neighborhood-Berechnung projiziert | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| F18 | Neighbourhood: Symmetrie N_ε(i) enthält j ↔ N_ε(j) enthält i | Paper Def.4 | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| F19 | Falsche Input-Klasse für tc_cluster → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| F20 | Cluster Summary: n_segs und n_trajs pro Cluster korrekt | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |

### G — Repräsentationsphase (Sweep-Line)

| # | Verhalten | Quelle | tdis | tsph | tcpp | thlp | tprt | tclst | trpr | test | ttrj | ttrc | tedg | tgld | twfl | tplt | tprs | thrd |
|---|-----------|--------|------|------|------|------|------|-------|------|------|------|------|------|------|------|------|------|------|
| G01 | Average Direction: Längere Segmente gewichten mehr (Raw-Vector-Sum) | Paper Formel 8 | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| G02 | Direction Cancellation: Magnitude < 1e-15 → fallback (1,0) + warning | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| G03 | Rotation zu Achse: cos/sin-Matrix korrekt (Paper Formel 9) | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| G04 | Inverse-Rotation: transponierte Matrix (echte Inverse) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| G05 | Entry/Exit Tie-Breaking: Entries vor Exits bei gleichem x | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| G06 | Y-Interpolation: arithmetischer Mittelwert der aktiven Segmente am Waypoint-x | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| G07 | Trajectory Diversity Check: Waypoint übersprungen wenn alle aktiven Segmente aus einer Trajektorie | Code (Paket-Erweiterung) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| G08 | Diversity Check: nur relevant wenn min_lns < 3 | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| G09 | Gamma-Smoothing: Waypoint übersprungen wenn Abstand < gamma zum letzten | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ |
| G10 | Gamma sehr groß → wenige Waypoints | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| G11 | < 2 Waypoints → Cluster degradiert zu Noise | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| G12 | Cluster-Renumbering nach Sweep-Line Degradation | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| G13 | Geographic + Haversine: per-Cluster-Zentrumprojektion | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ |
| G14 | Geographic + Projected: gespeicherter lat_mean verwendet | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| G15 | Euclidean: keine Projektion | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| G16 | min_lns aus tc_cluster geerbt wenn repr_min_lns=NULL | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| G17 | repr_min_lns überschreibt geerbtes min_lns | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| G18 | Falsche Input-Klasse für tc_represent → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| G19 | gamma <= 0 → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| G20 | Waypoint-Koordinaten korrekt nach Rück-Rotation | Paper+Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |

### H — Parameterschätzung

| # | Verhalten | Quelle | tdis | tsph | tcpp | thlp | tprt | tclst | trpr | test | ttrj | ttrc | tedg | tgld | twfl | tplt | tprs | thrd |
|---|-----------|--------|------|------|------|------|------|-------|------|------|------|------|------|------|------|------|------|------|
| H01 | Entropy-Formel: -Σ(p_i * log2(p_i)) korrekt berechnet | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| H02 | Tie-Breaking: kleinster eps bei gleichem Entropy-Minimum | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| H03 | eps_grid=NULL: 5.–95. Perzentil der Pairwise-Distanzen | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| H04 | eps_grid Degenerate (q5 >= q95): Fallback-Logik | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| H05 | sample_size > n_segments → alle Segmente verwendet | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| H06 | sample_size < n_segments → sample_size Segmente zufällig | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| H07 | min_lns-Schätzung: ceiling(mean_nb_size @ optimal_eps) + 1 | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| H08 | Optimales eps liegt innerhalb des übergebenen Grids | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| H09 | entropy_df Output enthält eps-Werte und Entropy-Werte | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| H10 | Gewichte (w_perp, w_par, w_angle) nicht geschätzt → Input-Werte unverändert | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

### I — S3-Methoden (print / summary / plot)

| # | Verhalten | Quelle | tdis | tsph | tcpp | thlp | tprt | tclst | trpr | test | ttrj | ttrc | tedg | tgld | twfl | tplt | tprs | thrd |
|---|-----------|--------|------|------|------|------|------|-------|------|------|------|------|------|------|------|------|------|------|
| I01 | print.tc_trajectories: invisible(x) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ♻ | ✗ |
| I02 | print.tc_trajectories: n_trajectories, n_points, method gezeigt | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ |
| I03 | print.tc_partitions: invisible(x) | Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ♻ | ✗ |
| I04 | print.tc_clusters: eps-Unit korrekt (meters vs. coords) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ♻ | ✗ |
| I05 | print.tc_representatives: invisible(x) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ♻ | ✗ |
| I06 | print.tc_traclus: invisible(x) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ |
| I07 | summary.tc_trajectories: min/median/max Punkte pro Trajektorie | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ |
| I08 | summary.tc_partitions: Segment-Längen-Statistik | Code | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ♻ | ✗ |
| I09 | summary.tc_clusters: n_segs + n_trajs pro Cluster | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ |
| I10 | summary.tc_representatives: Waypoints pro Representative | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ♻ | ✗ |
| I11 | plot.tc_trajectories: läuft ohne Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ |
| I12 | plot.tc_partitions: show_points=TRUE zeigt charakteristische Punkte | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ |
| I13 | plot.tc_clusters: Noise-Segmente grau/gestrichelt | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ |
| I14 | plot.tc_clusters: Legend suppressed wenn > 10 Cluster + message | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ |
| I15 | plot.tc_representatives: show_clusters=TRUE/FALSE beide Modi | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ |
| I16 | plot.tc_estimate: Entropy-Kurve visualisiert | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ |
| I17 | tc_plot wrapper: dispatcht korrekt zu plot.*-Methoden | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ |
| I18 | asp-Berechnung: euclidean asp=1, geographic cos-korrigiert | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ |
| I19 | tc_leaflet: nur für geographic Daten | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ |
| I20 | tc_leaflet: Error bei euclidean Input | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ |
| I21 | tc_leaflet: show_points Parameter in tc_leaflet.tc_partitions | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ |
| I22 | tc_leaflet: method='projected' kompatibel | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ |
| I23 | tc_leaflet: > 10 Cluster → message statt Legend | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| I24 | print.tc_clusters: Non-default Gewichte gezeigt | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ♻ | ✗ |
| I25 | Alle S3-print-Methoden: kein Error bei 0 Clustern | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ |

### J — Daten-I/O (HURDAT2)

| # | Verhalten | Quelle | tdis | tsph | tcpp | thlp | tprt | tclst | trpr | test | ttrj | ttrc | tedg | tgld | twfl | tplt | tprs | thrd |
|---|-----------|--------|------|------|------|------|------|-------|------|------|------|------|------|------|------|------|------|------|
| J01 | Datei nicht gefunden → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |
| J02 | Latitude N/S → korrekte Vorzeichen (+/-) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |
| J03 | Longitude E/W → korrekte Vorzeichen (+/-) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |
| J04 | Ungültige Richtung → NA → Punkt gefiltert | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |
| J05 | min_points Filter: Stürme mit < min_points → entfernt, warning | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |
| J06 | min_points Filter: Stürme mit >= min_points → behalten | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |
| J07 | min_points = 1 → alle Stürme mit >= 1 Punkt behalten | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |
| J08 | Ungültiger min_points-Typ → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |
| J09 | Output kompatibel mit tc_trajectories (storm_id, lon, lat Spalten) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ♻ |
| J10 | .parse_hurdat2_coord: skalare Eingabe | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |
| J11 | .parse_hurdat2_coord_vec: vektorisierte Eingabe konsistent mit skalarer | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |

### K — Integration & Pipeline

| # | Verhalten | Quelle | tdis | tsph | tcpp | thlp | tprt | tclst | trpr | test | ttrj | ttrc | tedg | tgld | twfl | tplt | tprs | thrd |
|---|-----------|--------|------|------|------|------|------|-------|------|------|------|------|------|------|------|------|------|------|
| K01 | tc_traclus() ohne eps → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| K02 | tc_traclus() ohne min_lns → Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| K03 | tc_traclus() = manuell tc_partition|tc_cluster|tc_represent | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| K04 | Reference Chain: result$clusters$partitions$trajectories vorhanden | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ♻ | ✗ | ✗ | ♻ | ✗ | ✗ | ✗ |
| K05 | eps an tc_cluster weitergegeben | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| K06 | gamma nur an tc_represent weitergegeben (nicht tc_cluster) | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| K07 | repr_min_lns überschreibt min_lns in tc_represent | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| K08 | Pipe-Operator |> kompatibel (alle Funktionen returnen Objekt) | Code | ✗ | ✗ | ✗ | ✗ | ✓ | ⚠ | ✗ | ✗ | ✗ | ✗ | ✗ | ⚠ | ♻ | ✗ | ✗ | ✗ |
| K09 | Re-Clustering: gleiche tc_partitions, andere eps/min_lns → keine Re-Partition | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ |
| K10 | Output-Klasse: tc_traclus erbt von tc_representatives | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ♻ | ✗ | ✓ | ✗ | ♻ | ✗ | ✗ |
| K11 | verbose=TRUE durch alle 3 Pipeline-Schritte propagiert | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| K12 | w_perp, w_par, w_angle durch gesamte Pipeline | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| K13 | Parameter-Validierung in tc_traclus vor Berechnung → early Error | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| K14 | Euclidean Vollpipeline: tc_traclus gibt gültiges Ergebnis | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ♻ | ✗ | ✓ | ♻ | ✗ | ⚠ | ✗ |
| K15 | Geographic Vollpipeline (haversine): tc_traclus gibt gültiges Ergebnis | Code | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

---

## Befunde: Redundanzen

### R1 — test-print-summary.R (tprs) fast vollständig redundant

7 von ~9 relevanten Tests sind ♻ gegenüber den Modul-Testdateien:

| Zeilen | Redundant gegenüber |
|--------|---------------------|
| I01 print.tc_trajectories invisible | ttrj |
| I03 print.tc_partitions invisible | tprt |
| I04 print.tc_clusters eps-Unit | tclst |
| I05 print.tc_representatives invisible | trpr |
| I08 summary.tc_partitions Segment-Längen | tprt |
| I10 summary.tc_representatives Waypoints | trpr |
| I24 print.tc_clusters Non-default Gewichte | tclst |

Nur I02, I06, I07, I09 bieten marginalen Mehrwert (Ausgabe-Content statt nur invisible/kein Error).

### R2 — test-helpers.R (thlp): Distanzvalidierungstests redundant

A28, A29, A37 — Input-Validierung (numeric length-2, finite Koordinaten, ungültiger method) wird in tdis explizit abgedeckt. thlp-Tests prüfen dieselben Error-Conditions ohne zusätzlichen Kontext.

### R3 — test-workflow-integration.R (twfl): Projektions-Pipeline redundant

E10, E11 (equirectangular-Projektion vor/nach Partitionierung) und E19 (haversine Partitionierung) werden durch tgld abgedeckt. K08 (Pipe-Operator kompatibel) wird durch tprt abgedeckt.

### R4 — test-tc_traclus.R (ttrc): Pipeline-Konsistenz redundant

- D23, D25, D32 (Preprocessing-Prüfungen) sind in ttrj abgedeckt.
- K04 (Reference Chain) wird durch trpr abgedeckt.
- K10 (tc_traclus erbt tc_representatives) und K14 (Euclidean Vollpipeline) werden durch tgld abgedeckt.

### R5 — Kleinere Einzelredundanzen

- B03 (Haversine Identische Punkte) in tedg → tsph deckt ab.
- D40 (.truncate_ids) in ttrj → thlp deckt ab.
- J09 (Output kompatibel mit tc_trajectories) in thrd → twfl deckt ab.

---

## Befunde: Fehlende Tests

### CRITICAL

| # | Zeile | Beschreibung |
|---|-------|-------------|
| C-1 | A33 / F13 | **Alle Gewichte = 0 → degenerierter Distanzfall.** tc_dist_segments gibt 0 für alle Paare zurück → alle Segmente in ε-Nachbarschaft → ein einziger Riesencluster. Kann bei automatischer Parameterwahl auftreten. Undokumentiert und ungetestet. |
| C-2 | H01 | **Entropy-Formel** (-Σ p_i × log2(p_i)) korrekt implementiert. Einzige Grundlage für tc_estimate_params-Empfehlungen; Formelkorrektheit wird nie direkt verifiziert (nur dass Output eps-Werte enthält). |
| C-3 | K15 | **Geographic Vollpipeline (haversine)** fehlt komplett: Kein End-to-End-Test von tc_trajectories → tc_partition → tc_cluster → tc_represent mit coord_type='geographic'. Test in thrd endet vor Clustering. |
| C-4 | C07 / C08 | **Early Termination: spezifische Abbruchpunkte** (accumulated > eps nach d_perp allein; nach d_perp+d_par). C09 prüft nur partial >= full, nicht welche Komponente auslöst. Stille Korrektheitsabweichungen möglich. |

### HIGH

| # | Zeile | Beschreibung |
|---|-------|-------------|
| H-1 | A10 | d_perp: l1 = l2 = 0 (beide Projektionen auf Li = 0) → Lehmer-Mittel 0/0; erwartetes Ergebnis: 0. |
| H-2 | A26 | d_angle: Null-Länge Li (len_i < 1e-15) → erwartet len_j. Asymmetrie zu A25 (Null-Länge Lj → 0), kein Test. |
| H-3 | B08 | Bearing: Identische Punkte (Δlat=0, Δlon=0) → atan2(0,0). Kein Crash-Test. |
| H-4 | B11 / B14 | Numerische Sicherheit sphärisch: sin_xt auf [-1,1] geklemmt (B11) und cos_xt < 1e-15 Guard (B14). |
| H-5 | B23 / B24 | d_angle_sph: Null-Länge Lj → 0 und Null-Länge Li → len_j. Analoge Lücken zu A25/A26. |
| H-6 | C10 / C11 / C12 | Early Termination: w_perp/w_par/w_angle = 0 → jeweilige Distanzkomponente gar nicht berechnet. |
| H-7 | D04 | coord_type ungültig (z.B. 'cartesian') → Error. D01–D03 nur ⚠ (R-Standardfehler). |
| H-8 | D05 / D06 | x-Spalte / y-Spalte nicht in Daten → Error. Fehlen komplett (D07 für traj_id ist vorhanden). |
| H-9 | E09 | Alle Segmente zero-length nach Partitionierung → Error. E08 (einige zero-length) nur ⚠. |
| H-10 | H04 | eps_grid degeneriert (q5 >= q95): Fallback-Logik nicht getestet. |
| H-11 | H07 | min_lns-Schätzungsformel: ceiling(mean_nb_size @ optimal_eps) + 1. Nur Output-Präsenz (H09) geprüft. |
| H-12 | K03 | tc_traclus() Ergebnis identisch mit manueller Kette tc_partition |> tc_cluster |> tc_represent. Kein Konsistenztest. |

### MEDIUM

| # | Zeile | Beschreibung |
|---|-------|-------------|
| M-1 | B26 / B27 | Haversine-Koordinaten außerhalb Gültigkeitsbereich (Lat > 90, Lon > 180) → warning. |
| M-2 | D09 | y-Spalte nicht numerisch → Error. D08 (x-Spalte) ist vorhanden, D09 fehlt. |
| M-3 | D18 / D19 | sf-Objekt mit Z/M-Dimensionen (→ message) und mit nicht-POINT-Geometrie (→ Error). |
| M-4 | D24 | Nicht-aufeinanderfolgende Duplikate → sollen NICHT entfernt werden. Dieses bewusste Nicht-Filtern hat keinen Test. |
| M-5 | D29 / D30 | geographic + x außerhalb [-180,180] bzw. y außerhalb [-90,90] → warning. |
| M-6 | G13 | Geographic + Haversine: per-Cluster-Zentrumprojektion. Nur ⚠ in twfl, keine explizite Verifikation der lat_mean-Berechnung pro Cluster. |
| M-7 | I23 | tc_leaflet: > 10 Cluster → message statt Legend. Einzige I-Zeile ohne jegliche Abdeckung. |

### LOW

| # | Zeile | Beschreibung |
|---|-------|-------------|
| L-1 | A38 | Distanz-Dreiecksungleichung kann verletzt werden (kein Test, aber als Regressionsdokumentation sinnvoll). |
| L-2 | D01–D03 | Fehlende Pflichtparameter (x, y, coord_type) → nur ⚠ via R-Standardfehler; kein paketspezifischer Error-Message-Test. |
| L-3 | B20 | d_angle_sph: Bearing-Differenz auf [0°, 180°] normalisiert — nur ⚠ in tsph (implizit durch d_angle_sph-Tests). |

---

## Befunde: Weitere Punkte

### W1 — test-print-summary.R: Refokussierung empfohlen

tprs ist in der aktuellen Form fast wertlos (7/9 Tests redundant). Empfehlung: Datei auf Grenzfälle fokussieren, die in Modul-Testdateien nicht abgedeckt sind — z.B. 0 Cluster im Output, degenerate Objekte, oder die Ausgabe-Inhalte (Formatierung, Zahlen) statt nur `invisible()`.

### W2 — Fehlende Matrixzeile für filepath-Typvalidierung in J

"invalid filepath type gives error" (tc_read_hurdat2(123)) ist in thrd vorhanden, hat aber keine entsprechende J-Matrixzeile. Die Prüfung auf nicht-character filepath ist ein eigenes Verhalten (J01 deckt nur file-not-found ab).

### W3 — Einziger Performance-Test im gesamten Paket

"parser reads large file in reasonable time" (thrd) ist der einzige systemische Performance-Test. Kein Performance-Test für Partitionierung, Clustering oder Repräsentation bei großen Datensätzen. Für ein trajectory-clustering-Paket relevant.

### W4 — Implizite D01/D02/D03-Fehlerbehandlung

Fehlende Pflichtparameter in tc_trajectories erzeugen R-Standard-Fehler ohne paketspezifische Fehlermeldung. Inconsistent mit der Sorgfalt in D07–D40 (alle paketspezifisch mit klaren Fehlermeldungen).

### W5 — G05 Entry/Exit Tie-Breaking ist abgedeckt (kein Handlungsbedarf)

Im Plan als "wahrscheinliche Lücke" markiert. trgr hat ✓ für G05. Kein Handlungsbedarf.

### W6 — tgld vs. ttrc Overlap bei Euclidean Vollpipeline

test-golden-scenarios.R und test-tc_traclus.R testen beide die euklidische Vollpipeline (K14 ♻). Empfehlung: ttrc auf geographic/parametervariationen fokussieren; tgld als einziger Hüter von K14.

---

## Executive Summary

**Gesamtbild:** Die Testsuite umfasst 16 Testdateien mit ~244 testbaren Verhaltenseinheiten in der Coverage Matrix.

| Kategorie | Anzahl | Anteil |
|-----------|--------|--------|
| Explizit getestet (≥1 ✓) | ~192 | ~79 % |
| Nur implizit abgedeckt (⚠ only) | ~19 | ~8 % |
| Keine Abdeckung (all ✗) | ~33 | ~14 % |
| Redundante Testzellen (♻) | ~24 Zellen | — |

**Top-Lücken (CRITICAL):**

1. **Geographic Vollpipeline (K15)** — Das Paket hat keine End-to-End-Tests mit `coord_type='geographic'`. Alle Vollpipeline-Tests sind euklidisch.
2. **Alle Gewichte = 0 (A33/F13)** — Degenerierter Fall; kann bei automatischer Parameterwahl unbemerkt auftreten.
3. **Entropy-Formel (H01)** — tc_estimate_params gibt Parameter zurück, aber die Formelkorrektheit wird nie direkt verifiziert.
4. **Early Termination Abbruchpunkte (C07/C08)** — Nur Gesamt-Property (partial >= full) getestet, nicht die spezifischen Abbruchstellen.

**Top-Redundanzen:**

1. **test-print-summary.R** — 7 von ~9 relevanten Tests redundant gegenüber Modul-Testdateien.
2. **test-tc_traclus.R** — Mehrere Pipeline-Tests redundant gegenüber tgld und trpr.
3. **test-workflow-integration.R** — Projektions-Pipeline redundant gegenüber tgld/tprt.

**Empfehlungen Priorität:**

1. `test-geographic-pipeline.R` neu anlegen (K15 + G13 + geografische Vollpipeline)
2. Gewicht=0-Test hinzufügen (A33/F13)
3. Entropy-Formel direkt testen (H01)
4. test-print-summary.R auf sinnvolle Grenzfälle refokussieren
5. Fehlende Input-Validierungstests nachziehen (D05/D06/D09, H-7 bis H-9)

| Metrik | Wert |
|--------|------|
| Gesamtzahl Verhaltenseinheiten | 254 |
| Abgedeckt (✓) | — |
| Indirekt (⚠) | — |
| Nicht abgedeckt (✗) | — |
| Redundant (♻) | — |
| CRITICAL-Lücken | — |
| HIGH-Lücken | — |
| MEDIUM-Lücken | — |
| LOW-Lücken | — |
