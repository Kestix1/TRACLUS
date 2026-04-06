Entwicklung des R-Pakets **TRACLUS**, das den TRACLUS Algorithmus implementiert.

**Allgemeine Anforderungen:**

* Das Paket soll open source auf GitHub und CRAN veröffentlicht werden
* Der Prefix für alle Funktionen ist "tc_".
* Lizenz: GPL-3 (kompatibel mit allen Dependencies: Rcpp ist GPL-2+, leaflet ist GPL-3)
* Gängige Konventionen des R-Kosmos sowie Best Practice werden durchgehend berücksichtigt
* Dokumentation mit roxygen2: Jede exportierte Funktion hat roxygen2-Kommentare mit @param, @return, @examples, @export. Dies generiert automatisch die NAMESPACE-Datei und die .Rd-Hilfeseiten. Examples die länger als 5 Sekunden dauern werden in \donttest{} gewrappt. Examples die Suggests-Pakete (sf, leaflet) nutzen werden mit if (requireNamespace(..., quietly = TRUE)) geschützt (CRAN-Vorgabe).
* Das Paket ist intuitiv, nutzerfreundlich und sehr gut dokumentiert
* Paketsprache ist englisch
<!-- GEÄNDERT: R >= 4.1.0 Begründung angepasst; skip_on_cran() entfernt -->
* CRAN-Implikationen: Vignetten bauen ohne Internet, Tests laufen in akzeptabler Zeit (< 10 Min), saubere Speicherverwaltung bei Rcpp ohne Compiler-Warnings. Depends: R (>= 4.1.0) in DESCRIPTION (für Kompatibilität mit modernen R-Features und Lambda-Syntax). C++-Code nutzt C++11 (R-Default seit 4.0) — keine zusätzlichen SystemRequirements oder Makevars-Einstellungen nötig. Tests sind schnell genug um alle auf CRAN zu laufen — `skip_on_cran()` wird nicht verwendet.
* NEWS.md zur Dokumentation von Änderungen zwischen Versionen (CRAN-Standard)
<!-- NEU: CRAN-Submission-Infrastruktur -->
* `CITATION.cff` im Repo-Root: aktiviert GitHub "Cite this repository"-Button; Format cff-version 1.2.0; enthält Titel, Version, Autor, Lizenz, Repository-URL
* `cran-comments.md` im Repo-Root: Pflicht für `devtools::release()`; enthält Testumgebungen und Reviewer-Hinweise; in `.Rbuildignore` ausgeschlossen
* `.github/RELEASE_CHECKLIST.md`: 7-stufige Pre-CRAN-Checkliste (Code → Tests → Docs → DESCRIPTION → CI → Submission → Post-Acceptance)
* `inst/WORDLIST`: Fachbegriffe für `spelling::spell_check_package()`
<!-- GEÄNDERT: Installationsanweisung auf pak::pak() aktualisiert -->
* README.md mit CRAN-Badge, R-CMD-check-Badge, test-coverage-Badge, Installationsanweisungen (`pak::pak("MartinHoblisch/TRACLUS")`), Minimalbeispiel (Toy-Dataset und Geographic-Beispiel), Parameter-Estimation-Beispiel, Workflow-Tabelle aller Funktionen und pkgdown-Link
* .Rbuildignore enthält: ^\.github$, ^docs$, ^pkgdown$, ^README\.Rmd$, ^LICENSE\.md$, ^\.lintr$, ^cran-comments\.md$ sowie Entwicklungs-Artefakte (^traclus_spec_final\.md$, ^traclus_structure\.md$, ^traclus_implementation_prompt\.md$, ^_pkgdown\.yml$, ^TRACLUS\.Rproj$, ^\.Rproj\.user$, ^\.claude$, ^figure$, ^todo\.md$, ^traclus_audit_prompt\.md$, ^dev$)
* Unit Tests mit testthat, inklusive Tests für Edge Cases. Unit Tests die R- und C++-Distanzfunktionen vergleichen nutzen eine Toleranz von 1e-10 (nicht exakte Gleichheit) um Floating-Point-Unterschiede zwischen R und kompiliertem Code zu berücksichtigen.
<!-- GEÄNDERT: CI/CD auf 8 Workflows erweitert (Prio 0+1 Roadmap 2026-04-07) -->
* CI/CD via GitHub Actions (8 Workflows):
  * `R-CMD-check.yaml` — R CMD check auf Windows, macOS, Ubuntu (release, devel, oldrel-1); `--as-cran` explizit; `error_on = "warning"` auf ubuntu/release (CRAN-Strenge); wöchentlicher Scheduled Run Mo 06:00 UTC (nur ubuntu/release); concurrency + workflow_dispatch
  * `test-coverage.yaml` — Coverage-Messung via covr + Codecov-Upload; concurrency + workflow_dispatch
  * `pkgdown.yaml` — pkgdown-Deployment via GitHub Pages bei push/release/workflow_dispatch; concurrency
  * `lint.yaml` — lintr-Check; `permissions: read-all`; concurrency + workflow_dispatch
  * `spelling.yaml` — `spell_check_package(error = TRUE)`; Fachbegriffe in `inst/WORDLIST` (TRACLUS, DBSCAN, haversine, Rcpp, …)
  * `urlchecker.yaml` — `url_check(parallel = TRUE)` prüft alle URLs in Rd, DESCRIPTION, README auf 404/Redirects
  * `asan.yaml` — ASAN/UBSAN via `ghcr.io/rocker-org/r-devel-san`; kritisch für Rcpp-Pakete (häufigste CRAN-Rejection-Ursache); push + workflow_dispatch; Artefakt-Upload bei Failure
  * `rhub.yaml` — r-hub v2 (kanonisches Format); nur workflow_dispatch; benötigt `RHUB_TOKEN` Secret (einmalig via `rhub::rhub_setup()`); testet auf linux, macos, windows, atlas
* Alle Workflows: `permissions: read-all` und `concurrency: cancel-in-progress: true`
* Professionelle pkgdown-Site als GitHub-Landingpage, generiert aus Paketdokumentation und Vignettes. Bootstrap 5 Theme, strukturierter Reference-Index (Workflow, Helpers, Distance Functions, Visualisation, Print/Summary, Data, Package)
<!-- NEU -->
* **Code-Stil**: Tidyverse Style Guide (https://style.tidyverse.org/) als verbindlicher Standard.
  * **styler**: `styler::style_pkg(filetype = c("R", "Rmd"))` wird vor jedem Release ausgeführt. Formatiert alle R-Quelldateien, Tests und Vignetten-Chunks automatisch nach `styler::tidyverse_style()` (Default-Einstellungen). Keine separate `.styler`-Konfigurationsdatei — Zeilenlänge wird ausschließlich über `lintr` (`line_length_linter(120)`) enforced.
  * **lintr**: `.lintr`-Datei mit `line_length_linter(120)`, `object_name_linter(styles = c("snake_case", "dotted.case"))`, `commented_code_linter = NULL` (deaktiviert — math. Annotationen in Tests), `indentation_linter = NULL` (deaktiviert — styler übernimmt Formatierung), `object_length_linter(length = 40L)` und `exclusions` für `object_usage_linter` in `tests/testthat` (Rcpp-Funktionen und helper-Sichtbarkeit). Naming-Konvention: `snake_case` für Variablen/Funktionen, `dotted.case` für S3-Methoden (z.B. `tc_leaflet.tc_trajectories`). `camelCase` ist nicht erlaubt.
* Pipe-Kompatibilität: Alle Kernfunktionen sind chainbar mit |> oder %>%. Jede Funktion akzeptiert das Ergebnisobjekt des vorherigen Schritts als erstes Argument. Ausnahme: tc_estimate_params() gibt ein S3-Objekt zurück, das kein tc_*-Workflow-Objekt ist — die Pipe-Chain wird damit unterbrochen, das ist by Design und wird dokumentiert.
* Jede Kernfunktion prüft die Klasse des ersten Arguments und wirft bei falschem Typ einen stop() mit klarer Fehlermeldung (z.B. "Expected a 'tc_partitions' object. Run tc_partition() first." — Klassenname in einfachen Anführungszeichen).
* Da jede Phase ein neues Objekt zurückgibt ohne das Eingabeobjekt zu verändern, kann der Nutzer denselben Schritt mit verschiedenen Parametern wiederholen — ideal für Trial-and-Error beim Clustering. Dieses Design-Feature wird in der Dokumentation und im Parameter Guide hervorgehoben.
<!-- NEU -->
* DESCRIPTION enthält zusätzliche Standard-Felder: `LazyData: true`, `Encoding: UTF-8`, `Roxygen: list(markdown = TRUE)`, `RoxygenNote: 7.3.3`, `Config/testthat/edition: 3`

**Namespace-Strategie:**

* Externe Funktionen werden per `package::function()` aufgerufen (z.B. `viridisLite::viridis()`, `leaflet::addPolylines()`). Keine `@import`-Direktiven.
<!-- GEÄNDERT: Paket-Level-Dokumentation verwendet "_PACKAGE" Sentinel -->
* R/TRACLUS-package.R enthält die Paket-Level-Dokumentation: Verwendet das roxygen2-Sentinel `"_PACKAGE"` (moderne Konvention, generiert automatisch `@docType package` und `@name TRACLUS-package`). Enthält `@title` mit Kurzbeschreibung, `@description` mit Paketübersicht (erwähnt euclidean und spherical/haversine Distanzberechnung), `@references` mit Zitat von Lee, Han & Whang (2007) inkl. DOI, `@keywords internal` (verhindert Index-Eintrag der Paket-Hilfeseite), `@useDynLib TRACLUS, .registration = TRUE`, `@importFrom Rcpp sourceCpp`.
* DESCRIPTION enthält: URL: https://github.com/MartinHoblisch/TRACLUS, https://martinhoblisch.github.io/TRACLUS und BugReports: https://github.com/MartinHoblisch/TRACLUS/issues

**Export-Strategie:**

* Alle tc_*-Funktionen werden exportiert
<!-- GEÄNDERT: tc_plot als exportiertes Generic ergänzt -->
* Alle S3-Methoden (print, summary, plot, tc_leaflet) werden exportiert. Zusätzlich wird `tc_plot` als exportiertes Generic bereitgestellt (Convenience-Wrapper für `plot(x, ...)`).
* R-seitige Distanzfunktionen (tc_dist_perpendicular, tc_dist_parallel, tc_dist_angle, tc_dist_segments) werden exportiert als testbare, lesbare Referenzimplementierung
* C++-Funktionen und interne Helfer werden nicht exportiert (alle Rcpp-Exports tragen `@keywords internal`)

**Signaturen der R-seitigen Distanzfunktionen:**

* tc_dist_perpendicular(si, ei, sj, ej, method = "euclidean") — Perpendicular distance zwischen zwei Segmenten
* tc_dist_parallel(si, ei, sj, ej, method = "euclidean") — Parallel distance zwischen zwei Segmenten
* tc_dist_angle(si, ei, sj, ej, method = "euclidean") — Angle distance zwischen zwei Segmenten
* tc_dist_segments(si, ei, sj, ej, w_perp = 1, w_par = 1, w_angle = 1, method = "euclidean") — Gewichtete Gesamtdistanz
* Jeder Punkt (si, ei, sj, ej) ist ein numeric-Vektor der Länge 2. si/ei definieren Segment Li, sj/ej definieren Segment Lj. Die Swap-Konvention (Li = längeres Segment) wird intern angewendet. Bei exakter Längengleichheit (Floating-Point ==) wird das Segment mit dem kleineren Index als Li zugewiesen — diese Konvention muss zwischen R- und C++-Implementierung konsistent sein.
* Bei method = "euclidean" (Default): Koordinaten sind (x, y). Bei method = "haversine": Koordinaten sind (longitude, latitude) in Dezimalgrad, Distanzen werden in Metern berechnet.
* Eingabevalidierung via `.validate_dist_inputs()`: Prüft Länge 2, numerisch, finite, method ∈ {"euclidean", "haversine"}. Bei haversine: Plausibilitätswarnungen für lat/lon-Bereiche.
* Optimierung in `tc_dist_segments()`: Distanzkomponenten mit Gewicht 0 werden übersprungen.

**Dependencies:**

* Rcpp in Imports und LinkingTo
* viridisLite in Imports (kontinuierliche viridis-Skala für farbenblind-sichere Plots; viridisLite::viridis(n) zieht exakt n gleichmäßig verteilte, einzigartige Farben aus dem Spektrum — keine Wiederholungen, bei geringer Clusteranzahl gut unterscheidbar)
* RcppProgress in LinkingTo (C++-Header-Only-Bibliothek für Fortschrittsbalken bei langen Berechnungen)
* leaflet, sf, knitr und rmarkdown in Suggests. VignetteBuilder: knitr in DESCRIPTION. tc_leaflet()-Methoden prüfen per requireNamespace() ob leaflet verfügbar ist; sf wird nur benötigt wenn der Nutzer sf-Objekte übergibt — ebenfalls per requireNamespace() abgesichert.

**S3-Klassenarchitektur:**

Alle S3-Objekte sind Listen. Jedes Objekt speichert eine Referenz auf das Ergebnisobjekt des vorherigen Schritts und kopiert relevante Metadaten (coord_type, method). Die gesamte Kette ist lückenlos rückverfolgbar. Plot-Funktionen können so auf Daten aller vorherigen Schritte zugreifen.

* **tc_trajectories** — Liste mit: data (data.frame der Punkte), coord_type, method, n_trajectories, n_points. Bei method = "projected" zusaetzlich: proj_params (Liste mit lat_mean und lon_mean — Schwerpunkt aller Eingabepunkte, verwendet als Projektionsursprung fuer die equirectangulaere Projektion)
* **tc_partitions** — Liste mit: segments (data.frame der Liniensegmente, formale Spaltenstruktur siehe unten), trajectories (Referenz auf tc_trajectories-Objekt), n_segments, plus kopierte Metadaten (coord_type, method)
* **tc_clusters** — Liste mit: segments (data.frame mit Cluster-Zuordnung, formale Spaltenstruktur siehe unten; enthält alle Segmente inkl. Noise mit cluster_id = NA), cluster_summary (Übersicht pro Cluster: cluster_id, n_segments, n_trajectories), n_clusters, n_noise, params (eps, min_lns, w_perp, w_par, w_angle), partitions (Referenz auf tc_partitions-Objekt), plus kopierte Metadaten. Noise-Segmente sind über segments[is.na(cluster_id), ] zugreifbar — kein separates noise-Element, keine Redundanz.
* **tc_representatives** — Liste mit: segments (eigene Kopie des segments data.frame mit aktualisierten cluster_ids — renummeriert, fehlgeschlagene Cluster zu Noise degradiert), representatives (data.frame der repräsentativen Trajektorien, formale Spaltenstruktur siehe unten), clusters (Referenz auf das unveränderte tc_clusters-Objekt mit Prä-Cleanup-IDs, sodass die Transformation nachvollziehbar ist), n_clusters, n_noise, params (min_lns, gamma), plus kopierte Metadaten
* **tc_traclus** — Kein eigener Container. `tc_traclus()` gibt exakt dasselbe Objekt zurück wie `tc_represent()`, aber mit einer zusätzlichen Klasse: `class(res) <- c("tc_traclus", "tc_representatives")`. Dadurch erbt der Wrapper automatisch alle Methoden von tc_representatives via S3-Dispatch (plot, tc_leaflet), hat aber eigene print/summary-Methoden (um anzuzeigen, dass alle drei Phasen in einem Aufruf liefen). Kein Speicher-Overhead, keine Redundanz, die Referenzkette bleibt intakt.
<!-- GEÄNDERT: tc_estimate mit method-Feld und summary() ergänzt -->
* **tc_estimate** — Rückgabeobjekt von tc_estimate_params(). Liste mit: eps (geschätzter eps-Wert), min_lns (geschätzter min_lns-Wert), w_perp, w_par, w_angle (verwendete Gewichte, Input-Werte nicht geschätzt), entropy_df (data.frame mit eps- und Entropy-Werten für das Grid), method (kopiert aus tc_partitions, für korrekte Einheitenanzeige in print/summary). Eigene print(), summary() und plot() Methoden. print() zeigt Optimal eps mit Einheit (meters/coordinate units), Est. min_lns, Grid range, Gewichte (nur wenn ≠ 1). summary() erweitert print() um den Min-Entropy-Wert. plot() zeigt den Entropie-Plot (type = "b": Punkte und Linien) zur visuellen Inspektion der Entropiekurve; kein Optimum markiert.

**Formale Spaltenstruktur des segments data.frame:**

* traj_id (character): ID der Quell-Trajektorie. traj_id-Werte werden intern als character gespeichert — bei integer- oder factor-Input erfolgt eine automatische Konvertierung. Das wird in der Dokumentation von tc_trajectories() erwähnt.
* seg_id (integer): Segmentnummer innerhalb der Trajektorie (1-basiert)
* sx, sy (numeric): Startpunkt-Koordinaten
* ex, ey (numeric): Endpunkt-Koordinaten
* cluster_id (integer, nur nach Clustering): Cluster-Zuordnung, NA für Noise

**Formale Spaltenstruktur des representatives data.frame:**

* cluster_id (integer): Zugehöriger Cluster
* point_id (integer): Waypoint-Nummer innerhalb der repräsentativen Trajektorie (1-basiert)
* rx, ry (numeric): Waypoint-Koordinaten im Originalformat (Lon/Lat bei geographic, x/y bei euclidean)

Referenzkette: tc_representatives (/ tc_traclus) → tc_clusters → tc_partitions → tc_trajectories. Von jedem Objekt aus ist die gesamte Historie erreichbar.

Für jede Workflow-Klasse (tc_trajectories, tc_partitions, tc_clusters, tc_representatives, tc_traclus) gibt es:
<!-- GEÄNDERT: Fehlermeldungsformat mit Anführungszeichen, min_lns-Warnung dokumentiert -->
* print() — Kompaktübersicht via cat() (wenige Zeilen, z.B. Anzahl Trajektorien/Segmente/Cluster, Parameter, coord_type). Zeigt zusätzlich den Workflow-Status an, z.B. "Status: partitioned (run tc_cluster next)" oder "Status: clustered (run tc_represent next)" oder "Status: complete". Zeigt die eps-Einheit an: "(meters)" bei method = "haversine" oder "projected", "(coordinate units)" bei method = "euclidean". Bei print.tc_clusters(): Wenn min_lns < 3, wird ein Hinweis auf mögliche degenerierte Representatives ausgegeben mit Verweis auf ?tc_represent und die Parameter-Guide-Vignette. Gibt invisible(x) zurück — R-Konvention für Chainability und Vermeidung doppelter Ausgabe.
* summary() — Detaillierte Zusammenfassung via cat(). Gibt invisible(object) zurück. Inhalt je nach Klasse:
  * summary.tc_trajectories(): Punkte pro Trajektorie (min/median/max), Gesamtpunkte, coord_type, method.
  * summary.tc_partitions(): Segmente pro Trajektorie (min/median/max), Gesamtsegmente, Segmentlängen (min/median/max) mit Einheitsangabe (meters bei geographic, leer bei euclidean).
  * summary.tc_clusters(): Segmente pro Cluster (min/median/max), Quell-Trajektorien pro Cluster (min/median/max), Noise-Anteil (mit Prozentwert), eps-Einheit, min_lns.
  * summary.tc_representatives(): Waypoints pro Representative (min/median/max), Segmente pro Cluster (min/median/max), Trajektorien pro Cluster (min/median/max), Cluster-Details, verlorene Cluster, gamma, min_lns.
  * summary.tc_traclus(): Eigene Methode mit zusätzlichen Informationen: Input-Trajektorien und Partitioned-into-Segments (aus Referenzkette).
* plot() — Base-R-Visualisierung
* tc_leaflet() — Leaflet-Visualisierung (nur für geographische Daten)

Für tc_estimate gibt es:
* print() — Zeigt Optimal eps mit Einheit, Est. min_lns, Grid-Range, Gewichte (nur wenn ≠ 1) via cat(). Gibt invisible(x) zurück.
* summary() — Erweitert print() um den Min-Entropy-Wert. Gibt invisible(object) zurück.
* plot() — Entropie-Plot (type = "b": Punkte und Linien) zur visuellen Inspektion der Entropiekurve; kein Optimum markiert

**Koordinatensystem und Distanzberechnung:**

* coord_type und method haben unterschiedliche Rollen: coord_type beschreibt die Natur der Daten (steuert Validierung, Koordinatenkonvention x=Longitude/y=Latitude, tc_leaflet-Freischaltung). method bestimmt die Distanzberechnung. Beide sind noetig weil verschiedene Kombinationen sinnvoll sind: Paper-Replikationsmodus (geographic + euclidean) und die performante Projektion (geographic + projected).
* Alle drei Phasen (Partitionierung, Clustering, Repräsentation) nutzen konsistent dieselbe Distanzmethode, bestimmt durch coord_type und method. Es gibt keine Mischung von Distanzmetriken zwischen den Phasen. Einzige Differenzierung: Die MDL-Kostenfunktion in der Partitionierung nutzt nur perpendicular distance und angle distance (ohne Gewichtung, ohne parallel distance), wie im Originalpaper beschrieben. Die Gewichtungsparameter w_perp, w_par, w_angle haben keinen Einfluss auf die Partitionierung — sie wirken ausschließlich auf die Clustering-Distanz.
* Gewichtete Gesamtdistanz für das Clustering: dist(Li, Lj) = w_perp × d_perp(Li, Lj) + w_par × d_par(Li, Lj) + w_angle × d_angle(Li, Lj). Dies ist die Formel aus dem Originalpaper (Section 2.3).
* Für alle drei Distanzkomponenten gilt die Konvention aus dem Originalpaper: Das längere Segment wird als Li, das kürzere als Lj zugewiesen (Swap vor Berechnung). Die perpendicular und parallel distance projizieren die Endpunkte von Lj auf die **Gerade** durch Li (nicht auf das Segment). Die Projektion darf außerhalb des Segments liegen — das ist gewollt. Die drei Komponenten bilden eine orthogonale Dekomposition: perpendicular misst den Abstand quer zur Geraden, parallel misst den Overshoot längs über das Segment hinaus, angle misst die Richtungsdifferenz. Diese Konvention stellt die Symmetrie der Distanzfunktion sicher (dist(A,B) = dist(B,A)).
* Perpendicular distance (Paper Def. 1): Für jeden Endpunkt von Lj (sj, ej) wird der senkrechte Abstand zur **Geraden** durch Li berechnet. Die beiden Einzeldistanzen l⊥1 (von sj) und l⊥2 (von ej) werden via Lehmer-Mittel 2. Ordnung kombiniert: d_perp = (l⊥1² + l⊥2²) / (l⊥1 + l⊥2). Guard-Clause: wenn l⊥1 + l⊥2 < numerische Toleranz (1e-15), dann d_perp = 0 (verhindert 0/0 bei fast kollinearen Segmenten). Bei sphärischer Berechnung werden l⊥1 und l⊥2 als Cross-Track-Distanzen zum **Großkreis** durch Li in Metern berechnet. Cross-Track-Distanzen werden als **Absolutwerte** verwendet — das Vorzeichen (das angibt auf welcher Seite des Großkreises der Punkt liegt) wird verworfen. Dann wird mit derselben Lehmer-Formel kombiniert.
* Parallel distance (Paper Def. 2): Die Endpunkte von Lj werden auf die **Gerade** durch Li projiziert. l∥1 ist der Abstand des projizierten Startpunkts von Lj zum näheren Endpunkt von Li, l∥2 analog für den Endpunkt. d_par = min(l∥1, l∥2). Die Projektion kann außerhalb des Segments liegen. Bei sphärischer Berechnung werden die Projektionen als **vorzeichenbehaftete** Along-Track-Distanzen entlang des **Großkreises** durch Li berechnet. Das Vorzeichen ist nötig um festzustellen ob die Projektion vor si (negativ) oder hinter ei (> Segmentlänge) liegt: d_at_signed = sign(cos(bearing_to_point − bearing_of_Li)) × |d_at|. Aus den signed Along-Track-Werten werden l∥1 und l∥2 analog zur euklidischen Formel berechnet.
* Angle distance (Paper Def. 3): d_angle = length(Lj) × sin(θ) wenn θ < 90°, sonst d_angle = length(Lj). Bei sphärischer Berechnung: θ = bearing_diff = min(|bearing_Li - bearing_Lj|, 360° - |bearing_Li - bearing_Lj|), wobei jedes Bearing als Forward Azimuth (Start→End) berechnet wird. Length in Metern (Haversine-Distanz der Endpunkte). Das initiale Bearing ist eindeutig, recheneffizient (eine atan2-Berechnung pro Segment) und für typische TRACLUS-Segmente (nach Partitionierung relativ kurz) eine gute Approximation des Gesamtkurses.
* Alle sphärischen Berechnungen (Haversine, Cross-Track, Along-Track, Bearing) verwenden R = 6371000 Meter (mittlerer Erdradius). Dieser Wert wird als Paketkonstante definiert und dokumentiert.
* Bei coord_type = "geographic" und method = "haversine": Alle Distanzen werden in Metern berechnet. eps wird in Metern angegeben. Dies ist wissenschaftlich korrekter als das Originalpaper, das lat/lon als kartesische Koordinaten behandelt.
* Bei coord_type = "geographic" und method = "projected": Koordinaten werden einmalig equirectangular auf Meter projiziert (x' = lon × cos(lat_mean) × 111320, y' = lat × 111320, wobei lat_mean der Schwerpunkt aller Eingabepunkte ist). Alle nachfolgenden Berechnungen (Partitionierung, Distanzen, Clustering) verwenden euklidische Distanzfunktionen im projizierten Raum. Ergebnisse (Segmente, Repräsentanten) werden zurück in lon/lat transformiert. eps und gamma werden in Metern angegeben, konsistent mit haversine. Genauigkeit: < 2% Fehler für regionale Gebiete (< 10° Ausdehnung) — ideal für HURDAT-Hurrikan-Daten, Taxi-Daten, Tier-Tracking etc. 5-10x schneller als haversine, da euklidische Distanzberechnung O(1) statt O(50-100) Floating-Point-Operationen pro Segmentpaar.
* Bei coord_type = "euclidean": Standard-euklidische Distanzberechnung, eps in der Einheit des Koordinatensystems.
* Optionaler Parameter method in tc_trajectories(). Default ist NULL. Nach Validierung wird method im S3-Objekt immer aufgelöst gespeichert — nie als NULL. Auflösungslogik (.resolve_method()):
  * coord_type = "geographic" + method = NULL → "haversine"
  * coord_type = "geographic" + method = "haversine" → "haversine"
  * coord_type = "geographic" + method = "projected" → "projected" (Projektionsparameter lat_mean/lon_mean werden berechnet und in proj_params gespeichert)
  * coord_type = "geographic" + method = "euclidean" → "euclidean" mit message() (Paper-Replikationsmodus)
  * coord_type = "euclidean" + method = NULL → "euclidean"
  * coord_type = "euclidean" + method = "haversine" oder "projected" → stop() (nicht kompatibel)
  * method wird von allen nachfolgenden Funktionen automatisch aus dem S3-Objekt ausgelesen — so ist sichergestellt, dass alle Berechnungsschritte konsistent dieselbe Distanzmethode verwenden.
* Koordinaten bleiben immer im Originalformat (lon/lat bzw. x/y). Was reingeht, kommt raus. Bei method = "projected" erfolgen Hin- und Ruecktransformationen (lon/lat ↔ Meter) transparent innerhalb der Berechnungsfunktionen — der Nutzer sieht stets lon/lat.
* Konvention bei geographischen Daten: x = Longitude (-180 bis 180), y = Latitude (-90 bis 90). Wird in der API-Dokumentation, in jeder Vignette und in Fehlermeldungen explizit kommuniziert. Die Validierung prüft auf vertauschte Koordinaten: wenn bei coord_type = "geographic" alle x-Werte in [-90, 90] und y-Werte außerhalb [-90, 90] liegen → Warnung: "It looks like x and y might be swapped. For geographic data, x = longitude (-180 to 180) and y = latitude (-90 to 90)."
<!-- GEÄNDERT: tc_represent Projektionsverhalten bei geographic+euclidean präzisiert -->
* Einschraenkung bei der Repraesentation: Die Representative Trajectory Generation nutzt stets lokale planare Approximation fuer das Sweep-Line-Verfahren. Bei method = "haversine" wird pro Cluster lokal equirectangular projiziert (lat_mean = Schwerpunkt des Clusters). Bei method = "projected" wird der globale Projektionsursprung (proj_params$lat_mean) verwendet — konsistent mit Partitionierung und Clustering. Bei method = "euclidean" und coord_type = "geographic" (Paper-Replikationsmodus) wird ebenfalls equirectangular projiziert — die Sweep-Line operiert auf Meter-Koordinaten, obwohl Partitionierung und Clustering mit euklidischen Distanzen auf Gradwerten arbeiten. Die gamma-Einheit ist in diesem Modus Meter (nicht Grad). Dies ist eine Inkonsistenz mit geringer praktischer Relevanz, da der Paper-Replikationsmodus ein Nischen-Anwendungsfall ist. In allen Faellen werden die Segmentkoordinaten auf Meter skaliert (x' = lon × cos(lat_mean) × 111320, y' = lat × 111320), nach dem Algorithmus zuruecktransformiert. Damit operieren gamma und die Sweep-Line in Metern, konsistent mit eps bei haversine/projected. Bei Clustern die sich ueber mehrere Grad erstrecken koennen geringfuegige Ungenauigkeiten auftreten.
* Bekannte Einschränkung: Trajektorien die den Anti-Meridian (180°/-180° Longitude) kreuzen können fehlerhafte Berechnungen erzeugen. Die Longitude-Normalisierung (falls angewendet, z.B. Shift auf [0°, 360°]) muss konsistent über alle drei Phasen angewendet werden: Partitionierung, Clustering UND Representative Trajectory Generation. Diese Einschränkung wird in der Spherical Geometry-Vignette dokumentiert mit dem Workaround, Longitudes vor der Verarbeitung auf [0°, 360°] zu verschieben. Einschränkung des Workarounds: Er funktioniert nur wenn keine Trajektorie sowohl den Nullmeridian als auch den Antimeridian kreuzt. Für transpazifische Routen ist eine robustere Lösung nötig, die in V1 nicht implementiert ist — das wird ehrlich kommuniziert.

**Berechnung — C++/R-Aufteilung:**

* **Phase 1 (Partitionierung) und Phase 2 (Clustering): in C++ via Rcpp.** Das umfasst die MDL-Kostenfunktionen, alle Distanzberechnungen und die Neighbourhood-Berechnung. Die C++-Implementierung nutzt die Symmetrie der Distanzfunktion: Die äußere Schleife iteriert i von 0 bis N-1, die innere j von i+1 bis N (Dreiecksmatrix). Ergebnisse werden bidirektional in die pre-allozierte Adjazenzliste gespeichert (adj[i].push_back(j); adj[j].push_back(i)). Das halbiert die Berechnungen auf N(N-1)/2. Es wird keine vollständige Distanzmatrix materialisiert — nur Nachbarn innerhalb eps werden gespeichert. Das ist O(n²/2) in der Berechnung, aber O(n × k) im Speicher (k = durchschnittliche Neighbourhood-Größe). Die DBSCAN-Expansionslogik (Queue, Visited-Flags, Cluster-Zuweisung) kann in R mit pre-allozierten Buffern bleiben, da sie nicht rechenintensiv ist.
* **Performance-Optimierung: Early Termination.** Bei der gewichteten Distanzberechnung (w⊥ × d⊥ + w∥ × d∥ + wθ × dθ) kann nach jeder Komponente geprüft werden ob die akkumulierte Distanz bereits eps übersteigt. Da alle drei Komponenten nicht-negativ sind, können die restlichen Komponenten übersprungen werden. Das spart bei kleinem eps erheblich Rechenzeit.
* **Phase 3 (Repräsentation): in R.** Die Sweep-Line-Berechnung ist O(m log m) pro Cluster mit typischerweise wenigen hundert Segmenten pro Cluster — kein Performance-Problem. Komplexe Event-Logik ist in R lesbarer und debugbarer.
* **R-seitige Distanzfunktionen** (tc_dist_perpendicular, tc_dist_parallel, tc_dist_angle, tc_dist_segments) bleiben als exportierte, testbare Referenzimplementierung erhalten. Die C++-Distanzfunktionen replizieren dieselbe Logik intern. Diese Aufteilung wird in der Dokumentation benannt.
* Die sphärischen Distanzfunktionen (Haversine, Cross-Track, Along-Track, Bearing) werden in C++ und als R-Referenz implementiert. Die R-Referenz ist über den method-Parameter der tc_dist_*-Funktionen zugänglich.
* Saubere Speicherverwaltung bei Rcpp ohne Compiler-Warnings (CRAN-Vorgabe). Alle Datenstrukturen sind stack-basiert (std::vector). Keine new/delete-Aufrufe. Rückgabe über Rcpp-Typen (automatisches Memory Management via R GC). Keine opaken Pointer. Kein Memory-Leak-Risiko.
* **C++ Funktionen returnieren ausschließlich Rcpp/R-Standardtypen (List, DataFrame, NumericVector, IntegerVector).** Diese werden im R-Wrapper in die dokumentierte S3-Listenstruktur umgewandelt. Keine opaken Pointer (XPtr) oder C++-eigenen Typen in der R-Schnittstelle — das schützt vor Memory Leaks und GC-Problemen.
* **Numerische Absicherung:** Alle acos()-Aufrufe werden mit clamp(x, -1, 1) abgesichert, sowohl in R als auch in C++. Alle asin()-Aufrufe in Cross-Track ebenfalls geclampt. Haversine-Wert `a` geclampt auf [0, 1]. Dies verhindert NaN-Ergebnisse durch Floating-Point-Fehler bei Werten knapp außerhalb [-1, 1].
* **CRAN-Compliance: User Interrupts.** In den äußeren Schleifen der O(n²)-Neighbourhood-Berechnung in C++ wird periodisch Rcpp::checkUserInterrupt() aufgerufen (alle 1000 Iterationen der äußeren Schleife in traclus_neighbourhoods.cpp, alle 100 Trajektorien in traclus_partition.cpp, alle 100 Iterationen in traclus_estimate_params.cpp). Dies ist ein Rcpp-Feature, unabhängig von RcppProgress. CRAN verlangt, dass langlaufende C++-Funktionen durch den Nutzer abbrechbar sind.
<!-- NEU -->
* **C++ Test-Exports:** Zusätzliche Rcpp-Exports ausschließlich für Tests: `.cpp_partition_single` (Einzeltrajektorie-Partitionierung), `.cpp_mdl_costpar` und `.cpp_mdl_costnopar` (MDL-Kostenfunktionen). Ermöglichen Golden-Value-Tests der internen MDL-Logik.
<!-- NEU -->
* **C++ Parameterschätzung:** Zwei dedizierte C++-Funktionen für tc_estimate_params(): `.cpp_compute_pairwise_dists()` (paarweise Distanzen für Stichprobe) und `.cpp_count_neighbours_multi_eps()` (Neighbourhood-Größen und Entropie für mehrere eps-Kandidaten via Binary Search).
<!-- NEU -->
* **Numerische Konstanten:** `ZERO_THRESHOLD = 1e-15` in traclus_distances.h, `SPHERE_ZERO_THRESHOLD = 1e-15` in traclus_spherical.h, `PARTITION_BIAS = 1.0` in traclus_partition.h, `EARTH_RADIUS_M = 6371000.0` in traclus_spherical.h. Separate Definitionen für euklidische und sphärische Toleranzen (funktional identisch).

**Plotting — Base R:**

* **tc_plot()** — Convenience-Wrapper, der `plot(x, ...)` aufruft. Exportiertes Generic in NAMESPACE. Existiert, damit `?tc_plot` und F1 in RStudio die TRACLUS-Plot-Hilfe anzeigen (F1 auf `plot()` zeigt immer die Base-R-Hilfe). Beide Aufrufe — `tc_plot(x)` und `plot(x)` — sind identisch.
* Alle Plots nutzen eine kontinuierliche viridis-Skala (via viridisLite::viridis()) für farbenblind-sichere Darstellung. viridis(n) liefert exakt n einzigartige, gleichmäßig verteilte Farben — keine Wiederholungen, bei geringer Anzahl gut unterscheidbar.
* Aspect Ratio: Bei coord_type = "euclidean" wird asp = 1 gesetzt für verzerrungsfreie Darstellung. Bei coord_type = "geographic" wird asp dynamisch berechnet: asp = 1 / cos(mean(latitude) * pi / 180) — das korrigiert die Meridiankonvergenz für die Darstellung. Der Nutzer kann asp via ... überschreiben.
* Alle plot-Methoden akzeptieren ...-Durchreichung an base-plot-Parameter (main, xlim, ylim, cex etc.) — das ist R-Konvention. **Implementierungshinweis:** Argumente in ... werden vor dem Plotten geparst (via `.merge_plot_args()`), um Konflikte mit hartcodierten Plot-Parametern (wie col oder lwd für Repräsentanten) zu verhindern.
<!-- GEÄNDERT: Endpunktpunkte und Legendenunterdrückung dokumentiert -->
* **plot.tc_trajectories()** — Rohtrajektorien, farblich nach traj_id. Zusätzlich werden Punkte (pch=16, cex=0.6) an jeder Koordinate gezeichnet. Legende bei ≤ 10 Trajektorien; bei > 10 Trajektorien wird die Legende unterdrückt (ohne message()).
* **plot.tc_partitions()** — Liniensegmente in Trajektorienfarben. Characteristic Points (Partitionspunkte) werden mit schwarzem X markiert (pch=4). Parameter show_points = TRUE (Default), abschaltbar mit show_points = FALSE bei sehr vielen Partitionspunkten. Legende bei ≤ 10 Trajektorien; bei > 10 unterdrückt (ohne message()).
* **plot.tc_clusters()** — Segmente farblich nach Cluster-Zugehörigkeit. Noise-Segmente hellgrau gestrichelt (grey80, lty=2). Titel enthält die verwendeten Parameter (z.B. "TRACLUS Clustering (eps = 30, min_lns = 6)").
<!-- GEÄNDERT: Farbkonsistenz-Logik und Grauton präzisiert -->
* **plot.tc_representatives()** — Zwei Modi via Parameter show_clusters = FALSE (Default) / TRUE. show_clusters = FALSE: Repräsentative Trajektorien farbig mit schwarzer Outline darunter (lwd=4 schwarz + 2.5 Farbe) für Sichtbarkeit auf dichtem Hintergrund, zugehörige Cluster-Segmente grau (grey70). show_clusters = TRUE: Cluster-Segmente vollständig eingefärbt, repräsentative Trajektorien farbig in derselben Farbe mit schwarzer Outline darüber. Farbkonsistenz: Die viridis-Palette wird anhand der Original-Clusteranzahl (vor Cleanup) berechnet, und überlebende Cluster-IDs werden auf ihre Original-Farben gemapped — dadurch visuelle Konsistenz zwischen tc_clusters und tc_representatives. **Hintergrundsegmente:** Aktive Cluster-Segmente werden grau durchgezogen dargestellt (grey70), Noise-Segmente (inkl. durch Cleanup degradierte Segmente) grey80 gestrichelt (lty=2). Legende enthält ggf. Eintrag für "Noise". Bei >10 Clustern wird die Legende unterdrückt und stattdessen ein Hinweis ausgegeben via message(): "Legend suppressed (>10 clusters). Use summary() to see cluster details." Position überschreibbar mit legend_pos.
* **plot.tc_traclus()** — Erbt von plot.tc_representatives() via `NextMethod()`.

**Plotting — Leaflet:**

* Separate Generic tc_leaflet() mit S3-Methoden pro Klasse. Ausschließlich für geographische Daten; bei euklidischen Daten wird ein klarer Fehler geworfen. tc_leaflet()-Methoden geben ein leaflet-htmlwidget-Objekt zurück. Das ermöglicht weitere Leaflet-Customization via Piping: tc_leaflet(result) |> leaflet::setView(...).
* Die Darstellung in Leaflet entspricht der Darstellung im Base-R-Plot (gleiche Farblogik, gleiche Modi, gleiche viridis-Palette). Farben der repräsentativen Trajektorien stimmen immer mit den zugehörigen Segmenten überein. Representatives werden mit schwarzer Outline gezeichnet (weight=5 schwarz + weight=3 farbig). Bei >10 Clustern wird die Legende unterdrückt, konsistent mit dem Base-R-Verhalten. **Noise-Segmente** werden in dunklem Grau (#666666) mit Strichelung (dashArray) dargestellt (besser sichtbar gegen Basemap als Standard-Grau). Durch Cleanup degradierte Segmente werden einheitlich als Noise dargestellt (keine separate Kategorie "Removed Clusters").
<!-- GEÄNDERT: Characteristic Points als ✕-Marker dokumentiert -->
* tc_leaflet.tc_partitions() unterstützt show_points-Parameter: bei TRUE (Default) werden ✕-Marker (LabelOnlyMarkers mit Unicode-Multiplikationszeichen) an allen Segment-Endpunkten gesetzt — konsistent mit dem Base-R-Plot (pch=4 = X-Marker).
* Drei Basiskarten zur Wahl via Layer-Control: 1. CartoDB Positron (Default), 2. OpenStreetMap, 3. Esri World Imagery.
* tc_leaflet.tc_representatives() und tc_leaflet.tc_traclus() bieten denselben show_clusters-Parameter wie die Base-R-Plots. tc_leaflet.tc_traclus() erbt von tc_leaflet.tc_representatives() via `NextMethod()`.
<!-- GEÄNDERT: Leaflet-Labels für Representatives präzisiert -->
* Interaktivität — Tooltips werden als Leaflet **labels** (bei Hover) implementiert:
  * **tc_leaflet.tc_trajectories()** — Label: Trajectory ID
  * **tc_leaflet.tc_partitions()** — Label: "traj_id, Seg N"
  * **tc_leaflet.tc_clusters()** — Label: "Cluster ID, traj_id" (oder "Noise, traj_id")
  * **tc_leaflet.tc_representatives()** — Label auf Representatives: "Representative ID (N segments)". Label auf Segmenten: "Cluster ID, traj_id".
  * **tc_leaflet.tc_traclus()** — Erbt von tc_leaflet.tc_representatives().

**Statusmeldungen und Ausgabekonventionen:**

* Berechnungsfunktionen (tc_trajectories, tc_partition, tc_cluster, tc_represent, tc_traclus) nutzen message() für informative Zusammenfassungen nach jedem Schritt (z.B. "Loaded 1959 trajectories", "Partitioned 1959 trajectories into 35425 line segments.", "Clustering: 8 clusters, 2867 noise segments.", "Representatives: 3 trajectories (2 clusters lost to cleanup)."), steuerbar über verbose = TRUE.
* print() und summary() Methoden nutzen cat() — das ist R-Konvention, da sie explizit vom Nutzer aufgerufen werden und auf stdout schreiben sollen.
* Fortschrittsbalken bei langen Berechnungen via RcppProgress im C++-Code. Wird nur bei n > 5000 Segmenten angezeigt. Bei verbose = FALSE wird auch der Fortschrittsbalken unterdrückt. Zusätzlich Progress::check_abort() für Abbruch-Erkennung.
* Keine Berechnungsfunktion schreibt ohne explizite Nutzeranfrage auf stdout (CRAN-Konvention). message() geht auf stderr und ist mit suppressMessages() unterdrückbar.

**Parametervalidierung:**

* eps: muss positiv numerisch sein. Bei eps ≤ 0 → stop(). Einheit: Meter bei method = "haversine" oder "projected", Koordinateneinheit bei method = "euclidean".
* min_lns: muss positive Ganzzahl ≥ 1 sein. Bei Verletzung → stop(). min_lns hat drei Rollen: (1) Mindest-Neighbourhood-Größe für Core-Segmente im DBSCAN, (2) Mindest-Trajectory-Cardinality für Cluster-Retention, (3) Mindest-Segmentdichte für Waypoint-Generierung in der Repräsentation — ein Waypoint wird nur generiert wenn die Anzahl der an der Sweep-Position kreuzenden Segmente ≥ min_lns ist (Paper Figure 15, Line 7) **und** mindestens 2 verschiedene Trajektorien unter den aktiven Segmenten vertreten sind (Trajectory-Diversity-Check, siehe Abweichung F1 unter Schritt 4). Paper-Empfehlung: min_lns = avg|Nε(L)| + 1~3, typischerweise ≥ 5 (Section 4.4). Werte < 3 können zu degenerierten Representatives führen (siehe F1).
* gamma: muss positiv numerisch sein. Bei gamma ≤ 0 → stop(). Muss nicht ganzzahlig sein. Einheit: Meter bei method = "haversine" oder "projected" (da Sweep-Line auf metrisch skalierte equirectangular-Koordinaten operiert), Koordinateneinheit bei method = "euclidean". gamma und eps haben damit immer dieselbe Einheit.
* w_perp, w_par, w_angle: müssen nicht-negativ numerisch sein.
<!-- NEU -->
* sample_size (in tc_estimate_params): muss ≥ 2 sein. Bei Verletzung → stop().
* Alle Validierungen sind in `R/validators.R` zentralisiert: `.validate_eps()`, `.validate_min_lns()`, `.validate_gamma()`, `.validate_weights()`.

**Edge Cases:**

* Systematisch abfangen: einzelne Trajektorien, Trajektorien mit < 2 Punkten, doppelte aufeinanderfolgende Punkte, leere Cluster, extreme eps-Werte, NA-Werte in Koordinaten, numerische Instabilität bei Winkelberechnungen
* Trajektorien mit exakt 2 Punkten sind valide (ergeben 1 Segment, MDL-Partitionierung ergibt keinen Split). Nur Trajektorien mit < 2 Punkten werden entfernt.
* 0 Cluster (alles Noise): tc_cluster() gibt warning() aus dass keine Cluster gefunden wurden. tc_represent() erhält ein Objekt mit 0 Clustern und gibt ein leeres tc_representatives-Objekt zurück (keine repräsentativen Trajektorien) mit warning(). Kein stop() — der Nutzer soll seine Parameter anpassen können.
* Fehlgeschlagene Representatives: Wenn einzelne Cluster keine gültige Representative Trajectory produzieren (< 2 Waypoints), werden diese Cluster zu Noise degradiert. Die Cluster-IDs werden anschließend renummert (z.B. 1, 5, 7 → 1, 2, 3) für konsistente Farbzuweisung in Plots. Zähler (n_clusters, n_noise) werden aktualisiert. Die message() gibt aus wie viele Cluster verloren gingen.
* Jeder Edge Case erhält mindestens einen Unit Test
* Warnings bei vielen betroffenen Elementen: IDs werden auf die ersten 5 gekürzt via `.truncate_ids(max_show = 5)`, Rest zusammengefasst. Gilt für alle Warnings die IDs auflisten.

**Golden-Value-Tests:**

Zusätzlich zu Edge-Case-Tests und R-vs-C++-Konsistenzprüfungen enthält das Paket Golden-Value-Tests: Tests mit von Hand vorberechneten Erwartungswerten, die sicherstellen dass die Berechnungen nicht nur konsistent (R = C++), sondern auch korrekt sind. Jeder Golden-Value-Test definiert konkrete Eingabewerte und das mathematisch exakte Erwartungsergebnis.

Mindestens folgende Golden-Value-Tests sind erforderlich:

* **Distanzfunktionen (euklidisch):** Für mindestens zwei konkrete Segmentpaare (Pair A, B) werden d_perp (inkl. Lehmer-Mittel), d_par und d_angle von Hand berechnet und als Erwartungswerte hinterlegt. Die Tests prüfen sowohl die Einzelkomponenten als auch die gewichtete Gesamtdistanz.
* **Distanzfunktionen (sphärisch):** Für mindestens zwei geographische Segmentpaare (Pair C, D) werden Haversine-Distanz, Cross-Track-Distanz, Along-Track-Distanz (signed) und Bearing von Hand berechnet oder gegen eine vertrauenswürdige externe Referenz validiert (z.B. movable-type.co.uk Geodesy-Formeln). Die Erwartungswerte werden als Referenz im Test hinterlegt.
* **MDL-Partitionierung:** Für eine kurze Trajektorie (5-7 Punkte, z.B. L-Shape) werden die MDL-Kosten (L(H) und L(D|H)) von Hand berechnet und die erwarteten Characteristic Points hinterlegt.
* **DBSCAN-Clustering:** Für ein kleines Beispiel (6-10 Segmente mit bekannter räumlicher Anordnung) wird die erwartete Cluster-Zuordnung (inkl. Noise) von Hand bestimmt und als Referenz hinterlegt.
* **Sweep-Line-Repräsentation:** Für einen Cluster mit 4-5 Segmenten werden die erwarteten Waypoints der repräsentativen Trajektorie von Hand berechnet und als Referenz hinterlegt.

Golden-Value-Tests werden in den jeweiligen Phasen-Testdateien implementiert (test-distances.R, test-distances-spherical.R, test-tc_partition.R, test-tc_cluster.R, test-tc_represent.R), nicht in einer separaten Datei. Die handberechneten Erwartungswerte werden im Test-Code als Kommentar mit der vollständigen Herleitung dokumentiert.

<!-- NEU -->
**Golden-Scenario-Tests:**

Zusätzlich zu den oben genannten Golden-Value-Tests existieren 10 handkonstruierte Szenarien (S01–S11, P1) in `test-golden-scenarios.R` mit vollständiger Pipeline-Verifikation. Diese testen den gesamten Workflow end-to-end mit bekannten Eingaben und Erwartungswerten.

**Hilfsfunktionen:**

<!-- GEÄNDERT: sample_size Validierung und degeneriertes Grid Handling ergänzt -->
* tc_estimate_params(x, eps_grid = NULL, sample_size = 200L, w_perp = 1, w_par = 1, w_angle = 1, verbose = TRUE) — Optionales Hilfsmittel zur Parameterschätzung, kein vorgeschriebener Workflow-Schritt. sample_size muss ≥ 2 sein. Bei method = "projected" werden Segment-Koordinaten vor der Paarweisen-Distanzberechnung equirectangular auf Meter projiziert, sodass die geschaetzten eps-Werte in Metern vorliegen (konsistent mit tc_cluster). Schaetzt eps via Entropie-Minimierung der ε-Neighborhood-Groessen und min_lns als Funktion des geschaetzten eps, basierend auf der Heuristik aus dem Originalpaper (Section 4.4). min_lns wird als ceiling(durchschnittliche Neighbourhood-Größe bei optimalem eps) + 1 berechnet — ein einzelner Wert. Die Vignette empfiehlt, auch Werte ±2 um diesen Schätzwert zu testen. Wenn eps_grid = NULL (Default), wird ein intelligentes Grid generiert: Aus einer Zufallsstichprobe (sample_size Segmente, Default 200) werden paarweise Distanzen berechnet und das Grid von 50 gleichmäßig verteilten Werten vom 5. bis 95. Perzentil aufgespannt. Bei degeneriertem Grid (q5 >= q95, alle Distanzen nahezu gleich) wird der Grid-Bereich erweitert. Sowohl die Grid-Generierung als auch die Entropy-Berechnung operieren auf demselben Sample — das vermeidet O(N²) bei großen Datensätzen. Der sample_size-Parameter steuert die Stichprobengröße. Bei explizitem eps_grid wird sample_size ignoriert. Bei mehreren eps-Werten mit identischer minimaler Entropy wird der kleinste eps gewählt. Rückgabe: S3-Objekt der Klasse tc_estimate mit Elementen eps, min_lns, w_perp, w_par, w_angle (Input-Werte, nicht geschätzt), entropy_df (data.frame), method (aus tc_partitions kopiert). Eigene print()-Methode zeigt optimalen eps-Wert mit Einheit und Grid-Range. Eigene summary()-Methode erweitert print() um den Min-Entropy-Wert. Eigene plot()-Methode zeigt den Entropie-Plot (type = "b": Punkte und Linien) zur visuellen Inspektion der Entropiekurve; kein Optimum markiert — der Nutzer entscheidet wann er den Plot sehen will. Erwartet ein tc_partitions-Objekt als Input. Die Funktion liefert einen datenbasierten Startpunkt — die optimalen Werte werden typischerweise durch Trial-and-Error gefunden. Geschätzte Werte sind über result$eps und result$min_lns zugreifbar.

* tc_read_hurdat2(filepath, min_points = 3) — Parst die HURDAT2 Best-Track-Datei (NOAA NHC Format) und gibt einen data.frame mit Spalten storm_id, lat, lon zurück. West-Longitudes werden in negative Werte konvertiert; Output-lon folgt der Paketkonvention (-180 bis 180). Storms mit weniger als min_points Beobachtungen werden gefiltert. Direkt kompatibel mit tc_trajectories(data, traj_id = "storm_id", x = "lon", y = "lat", coord_type = "geographic"). Exportierte Hilfsfunktion, die die Real-World-Vignette selbstenthalten und reproduzierbar macht. Ein HURDAT2-Subset (1950–2004, passend zum Originalpaper) wird in inst/extdata mitgeliefert, damit die Vignette ohne Internetzugriff baut (CRAN-Vorgabe).

**Dokumentation:**

* Toy-Dataset: traclus_toy — Ein data.frame, gespeichert als data/traclus_toy.rda (R-Konvention für Beispieldatensätze). LazyData: true in DESCRIPTION, damit der Datensatz direkt als `traclus_toy` verfügbar ist, ohne `data()`-Aufruf. Dokumentiert via roxygen2 in R/data.R mit @format-Block. Euklidischer Datensatz.
* HURDAT2-Subset (1950–2004) in inst/extdata mitgeliefert für die Real-World-Vignette.
* inst/CITATION mit Referenz auf das Originalpaper (Lee, Han & Whang, SIGMOD 2007) und das Paket selbst, damit beides korrekt zitierbar ist.
* Vier Vignettes:
  1. **Get Started** (TRACLUS-get-started.Rmd) — Toy Dataset (`traclus_toy`), Algorithmus Schritt für Schritt erklärt, didaktisch, einfach. Inkl. Abschnitt "Which coord_type do I need?" als Tabellen-/Text-Guidance mit Entscheidungshilfe (erfundene Daten → euclidean, GPS/OSM-Daten → geographic, sf-Objekt → automatisch). Klare Erklärung der Koordinatenkonvention: x = Longitude, y = Latitude. Hebt hervor, dass dasselbe tc_partitions-Objekt mit verschiedenen eps/min_lns-Werten geclustert werden kann (Trial-and-Error Feature).
  2. **Real-World Example** (TRACLUS-real-world.Rmd) — HURDAT2-Hurricanedaten via tc_read_hurdat2() aus dem mitgelieferten Subset, praktischer Workflow mit tc_trajectories() → tc_traclus() → Leaflet-Karte. Zeigt den vollständigen Workflow. Zeigt zusätzlich den generischen Weg über tc_trajectories() für eigene Datenformate. Diskutiert transparent den Unterschied zwischen sphärischer und euklidischer Distanzberechnung am konkreten Beispiel.
  3. **Parameter Guide** (TRACLUS-parameter-guide.Rmd) — Ausfuehrliche technische Erlaeuterungen aller frei waehlbaren Parameter (eps, min_lns, gamma, Gewichte, method), mit Bezug zum Originalpaper. Stellt Trial-and-Error als primaeren Ansatz zur Parameterwahl dar und demonstriert, wie dasselbe tc_partitions-Objekt wiederholt mit verschiedenen Parametern geclustert werden kann. Stellt tc_estimate_params() als optionales Hilfsmittel vor, erklaert die Entropie-Heuristik, die intelligente Grid-Generierung und den sample_size-Parameter. Erklaert die method-Logik inklusive der drei Methoden: haversine (exakt, langsam), projected (equirectangulaere Projektion, schnell, < 2% Fehler fuer regionale Gebiete), euclidean (Paper-Replikation). Empfiehlt method = "projected" als pragmatische Wahl fuer die meisten geographischen Anwendungsfaelle und erklaert wann haversine vorzuziehen ist (grossraeumige, globale Datensaetze). Erklaert die min_lns-Dreifachrolle. Dokumentiert die gamma-Einheit (Meter bei haversine/projected, Koordinateneinheit bei euclidean — konsistent mit eps). Dokumentiert die Paper-Empfehlung zur konservativeren Partitionierung (Section 4.1.3). Verweist fuer sphaerische Geometrie-Details auf die Spherical Geometry-Vignette.
  4. **Spherical Geometry** (TRACLUS-spherical-geometry.Rmd) — Zusammenhängender Abschnitt der erklärt, wie TRACLUS (ein euklidischer Algorithmus) auf die Kugeloberfläche übertragen wird. Dokumentiert alle vier sphärischen Anpassungen: (1) Perpendicular distance → Cross-track distance (Absolutwerte) zum Großkreis mit Lehmer-Mittel 2. Ordnung zur Kombination der zwei Einzeldistanzen, (2) Parallel distance → vorzeichenbehaftete Along-track distance mit sphärischer Projektion auf den Großkreis von Li und min(l∥1, l∥2)-Kombination (Projektion darf außerhalb des Bogens liegen), (3) Angle distance → Forward Azimuth Bearing-Differenz mit expliziter Normalisierungsformel min(|b1-b2|, 360°-|b1-b2|), sin()-Term und 90°-Schwelle (erklärt warum das initiale Bearing verwendet wird und warum das für nach der Partitionierung typischerweise kurze Segmente eine gute Approximation ist), (4) Representative Trajectory → lokale Equirectangular-Projektion mit Meter-Skalierung (lon × cos(lat_mean) × 111320, lat × 111320) vor dem gesamten Sweep-Line-Algorithmus, mit Rücktransformation nach dem Algorithmus (Einschränkung bei großen Clustern). Dokumentiert zusätzlich die Anti-Meridian-Einschränkung mit Workaround und dessen Limitation. Mathematisch begründet, mit Bezug zum Originalpaper, benennt Einschränkungen explizit.
<!-- NEU -->
* Leaflet-Chunks in Vignetten verwenden `eval = requireNamespace("leaflet", quietly = TRUE)` im Chunk-Header als CRAN-konforme Guard für Suggests-Pakete.

---

**Schritt 1: Import der Nutzerdaten**

* Der Nutzer liest seine Daten selbst ein. Das Paket stellt eine Validierungs- und Konvertierungsfunktion bereit: tc_trajectories()
* tc_trajectories() ist keine S3-Generic — es ist eine einzelne Funktion die intern via inherits(data, "sf") den Eingabetyp prüft. Kein S3-Dispatch auf sf-Klassen, kein Namespace-Konflikt mit dem sf-Paket.
* API: tc_trajectories(data, traj_id, x = NULL, y = NULL, coord_type = NULL, method = NULL, verbose = TRUE)
* Bei data.frame/tibble: traj_id, x, y und coord_type sind Pflicht. Wenn x, y oder coord_type NULL sind → stop("x, y, and coord_type are required for data.frame input.")
* Bei sf-Objekten: Nur data und traj_id sind Pflicht. Erfordert requireNamespace("sf"); falls sf nicht installiert → stop("Package 'sf' is required to process sf objects. Install it with install.packages('sf')."). Geometrie muss POINT sein (inkl. POINT Z, POINT M, POINT ZM); bei anderen Geometrietypen → stop("sf input must have POINT geometry. Use sf::st_cast('POINT') to convert LINESTRING geometry."). sf-Objekte mit Z- oder M-Dimensionen: Nur X (Longitude) und Y (Latitude) werden extrahiert, zusätzliche Dimensionen werden stillschweigend verworfen mit einer message(). CRS muss vorhanden sein; bei fehlendem CRS (st_crs() gibt NA) → stop("sf object must have a valid CRS. Set one with sf::st_set_crs()."). x, y und coord_type werden automatisch aus der Geometry bzw. dem CRS abgeleitet (st_is_longlat()). Koordinaten werden intern aus der Geometry-Spalte in x/y-Spalten extrahiert, sodass das interne tc_trajectories-Objekt immer einen data.frame enthält — unabhängig vom Eingabetyp. Falls x, y oder coord_type dennoch explizit angegeben werden, wird geprüft ob sie konsistent mit dem sf-Objekt sind; bei Widerspruch wird gewarnt.
* traj_id: Spaltenname der Trajektorien-ID. Kann character, integer oder factor sein — relevant ist nur Eindeutigkeit pro Trajektorie (z.B. Hurricane-Namen, Schiffs-IDs, Tier-Kennungen). Werte werden intern als character gespeichert; bei integer- oder factor-Input erfolgt automatische Konvertierung.
* tc_trajectories() gruppiert die Zeilen intern nach traj_id (via `.group_by_traj_id()`) und bewahrt die Originalreihenfolge innerhalb jeder Gruppe. Der Input-data.frame muss nicht nach traj_id vorsortiert sein. Die Reihenfolge der Punkte innerhalb jeder Trajektorie wird durch die Zeilenreihenfolge im Input bestimmt — nicht durch eine Zeitstempel- oder Sequenzspalte.
* coord_type = "geographic" + method = NULL: Daten bleiben als lat/lon, method wird im Objekt auf "haversine" aufgeloest. Konvention: x = Longitude (-180 bis 180), y = Latitude (-90 bis 90).
* coord_type = "geographic" + method = "projected": Daten bleiben als lat/lon, Projektionsparameter (lat_mean, lon_mean als Schwerpunkt aller Eingabepunkte) werden berechnet und in proj_params gespeichert. Alle nachfolgenden Berechnungen projizieren transparent auf Meter, Ergebnisse werden zurueck in lon/lat transformiert. Performant (5-10x schneller als haversine), < 2% Fehler fuer regionale Gebiete.
* coord_type = "geographic" + method = "euclidean": Daten bleiben als lat/lon, euklidische Berechnung auf Gradwerten (Paper-Replikationsmodus). method wird im Objekt als "euclidean" gespeichert. Es wird eine message() ausgegeben: "Using euclidean distances on geographic coordinates (paper replication mode)."
* coord_type = "euclidean": method wird im Objekt auf "euclidean" aufgeloest. Bei method = "haversine" oder "projected" → stop() (nicht kompatibel mit euklidischen Koordinaten).
* Nach Validierung wird method im S3-Objekt immer aufgeloest gespeichert — nie als NULL.
* Erwartetes Datenformat: Tidy Data — eine Zeile pro Punkt, Spalten für ID, x, y. Reihenfolge der Zeilen = Reihenfolge der Punkte innerhalb der Trajektorie. Aufbereitung von Spezialformaten (z.B. HURDAT2) ist Vorarbeit des Nutzers oder via tc_read_hurdat2(), wird in der Real-World-Vignette gezeigt.
<!-- GEÄNDERT: Euclidean Plausibilitätswarnung und Antimeridian-Text präzisiert -->
* Validierung vierstufig:
  1. **Basisprüfungen:** Spalten existieren, x/y numeric und finit (geprüft via is.finite() — fängt NA, NaN und Inf/-Inf ab), Plausibilitätscheck mit Warnung (bei coord_type = "geographic": x außerhalb [-180, 180] oder y außerhalb [-90, 90]; vertauschte Koordinaten erkennen: wenn alle x in [-90, 90] und y außerhalb [-90, 90] → Warnung; bei coord_type = "euclidean": Erweiterte Heuristik prüft ob Daten Geodaten sein könnten — wird nur ausgelöst bei > 10 Datenpunkten, Spanne > 1, und Vorhandensein negativer oder großer Werte, um Fehlalarme bei kleinen euklidischen Toy-Datensätzen zu vermeiden). Bei coord_type = "geographic": Wenn aufeinanderfolgende Punkte innerhalb einer Trajektorie einen Longitude-Unterschied > 180° aufweisen, wird eine warning() ausgegeben: "Trajectory X appears to cross the antimeridian. See vignette('TRACLUS-spherical-geometry') for details." (via `.check_antimeridian()`).
  2. **Filtern (in dieser Reihenfolge):** (a) Zeilen mit nicht-finiten Werten in x, y oder NA in traj_id entfernen. (b) Aufeinanderfolgende Duplikate innerhalb von Trajektorien entfernen (exakte Koordinatengleichheit). (c) Trajektorien mit < 2 Punkten entfernen (kann durch vorherige Schritte entstehen).
  3. **Warnen:** Per warning() melden was entfernt wurde. Bei vielen betroffenen Elementen werden IDs auf die ersten 5 gekürzt via `.truncate_ids(max_show = 5)`, Rest zusammengefasst.
  4. **Endprüfung:** Nach dem Filtern: weniger als 2 gültige Trajektorien übrig → stop() mit klarem Fehler, da TRACLUS multiple Trajektorien zum Clustern benötigt.

**Schritt 2: Partitionierung**
* tc_partition(x, verbose = TRUE) — MDL-Kostenfunktion und Distanzberechnungen in C++
* Erstes Argument: tc_trajectories-Objekt (Klassenprüfung via `.check_class()`, stop() bei falschem Typ: "Expected a 'tc_trajectories' object. Run tc_trajectories() first.")
* Bei method = "projected": Eingabekoordinaten werden mit den gespeicherten proj_params equirectangular auf Meter projiziert, die C++-Partitionierung laeuft mit method_code = 0 (euklidisch), Segment-Endpunkte werden anschliessend zurueck in lon/lat transformiert. Der Nutzer sieht stets lon/lat in den Ergebnissen.
* Die MDL-Kostenfunktion nutzt perpendicular distance und angle distance zur Berechnung der Encoding-Kosten (L(H) und L(D|H)), wie im Originalpaper beschrieben (Formeln 6 und 7). Die Gewichtungsparameter w_perp, w_par, w_angle haben keinen Einfluss auf die Partitionierung. Innerhalb der MDL-Berechnung ist das Partitionssegment (das mehrere Originalpunkte überspannt) typischerweise das längere Segment Li. Die Swap-Konvention (Li = längeres Segment) gilt unconditional — auch im seltenen Fall dass ein Originalsub-Segment länger ist als der Partitionskandidat. Konsistent mit dem Paper (δ = 1): Alle log₂-Aufrufe in der MDL-Kostenfunktion verwenden log₂(max(x, 1.0)) um stark negative Werte bei Distanzen/Längen unter 1 zu vermeiden.
* Konsistent mit der Empfehlung in Paper Section 4.1.3 wird eine kleine additive Konstante (PARTITION_BIAS = 1.0) auf costnopar addiert um Over-Partitionierung zu vermeiden. Dies erzeugt längere Partitionen und verbessert die Clustering-Qualität (Paper: "increasing the length of trajectory partitions by 20~30% generally improves the clustering quality").
* Nach der Partitionierung: Segmente mit Länge 0 oder unterhalb einer numerischen Toleranz werden entfernt. Bei Auftreten wird eine warning() ausgegeben. Dies kann durch numerische Rundung oder dichte GPS-Punkte entstehen. Falls nach der Partitionierung und Null-Segment-Entfernung keine Segmente übrig sind → stop() mit klarer Fehlermeldung.
<!-- NEU -->
* Warnung bei vollständig verlorenen Trajektorien: Wenn durch Null-Segment-Entfernung komplette Trajektorien verloren gehen, gibt tc_partition() eine zusätzliche warning() aus.
* Rückgabe: tc_partitions-Objekt mit segments data.frame (Spalten: traj_id, seg_id, sx, sy, ex, ey)
* plot(ergebnis) / tc_leaflet(ergebnis)

**Schritt 3: Clustering**
* tc_cluster(x, eps, min_lns, w_perp = 1, w_par = 1, w_angle = 1, verbose = TRUE) — Neighbourhood-Berechnung in C++, DBSCAN-Expansionslogik in R mit pre-allozierten Buffern (dbscan.R)
* Erstes Argument: tc_partitions-Objekt (Klassenprüfung via `.check_class()`, stop() bei falschem Typ: "Expected a 'tc_partitions' object. Run tc_partition() first.")
* Bei method = "projected": Segment-Koordinaten werden mit den gespeicherten proj_params equirectangular auf Meter projiziert, die C++-Neighbourhood-Berechnung laeuft mit method = "euclidean". eps ist in Metern (konsistent mit haversine). Cluster-IDs haengen nicht vom Koordinatensystem ab — Ergebnis-Segmente behalten lon/lat.
* eps und min_lns haben keine Default-Werte. Die Funktionen prüfen via missing(eps) bzw. missing(min_lns) beim Eintritt und werfen die custom Fehlermeldung: "'eps' and 'min_lns' are required. Choose values by trial and error or use tc_estimate_params() after tc_partition() for a data-driven starting point." Parametervalidierung: eps > 0, min_lns ≥ 1.
* DBSCAN-Expansionslogik (`.dbscan_expand()`): Wenn ein Segment M als Core identifiziert wird, werden alle Segmente in seiner ε-Neighbourhood dem aktuellen Cluster zugewiesen — auch Segmente die vorher als Noise markiert waren. Jedoch werden nur bisher unklassifizierte Segmente in die Expansions-Queue eingefügt. Reklassifizierte Noise-Segmente lösen keine weitere Expansion aus (Paper Figure 12, Zeilen 23-26). Core-Segment-Check: `length(nb_i) + 1L < min_lns` — das +1 berücksichtigt das Segment selbst (Nε(L) ist self-inclusive, aber Adjazenzlisten enthalten nur andere Segmente).
* Nach dem Clustering: Trajectory-Cardinality-Check — Cluster deren Segmente aus weniger als min_lns verschiedenen Trajektorien stammen werden entfernt. Segmente aus diesen Clustern werden zu Noise degradiert (cluster_id = NA). Cluster-IDs werden renummert via `.renumber_clusters()` (lückenlos 1..K).
* Bei 0 Clustern (alles Noise): warning() "No clusters found (all segments are noise)." ausgeben, tc_clusters-Objekt mit 0 Clustern zurückgeben. Kein stop().
* Rückgabe: tc_clusters-Objekt mit segments data.frame (Spalten: traj_id, seg_id, sx, sy, ex, ey, cluster_id)
* plot(ergebnis) / tc_leaflet(ergebnis)

**Schritt 4: Repräsentation**
* tc_represent(x, gamma = 1, min_lns = NULL, verbose = TRUE) — Berechnung in R (Sweep-Line, O(m log m) pro Cluster)
* Erstes Argument: tc_clusters-Objekt (Klassenprüfung via `.check_class()`, stop() bei falschem Typ: "Expected a 'tc_clusters' object. Run tc_cluster() first.")
* gamma: Smoothing-Parameter (Mindestabstand zwischen aufeinanderfolgenden Waypoints), Default 1. Parametervalidierung: gamma > 0. Einheit: Meter bei method = "haversine" oder "projected" (da Sweep-Line auf metrisch skalierte equirectangular-Koordinaten operiert), Koordinateneinheit bei method = "euclidean". Im Parameter Guide wird erlaeutert wie man gamma waehlt.
* min_lns: Default NULL → wird aus x$params$min_lns gelesen (Clustering-Wert). Überschreibbar für Power-User. Bei Überschreibung wird eine message() ausgegeben: "Using custom min_lns = %d for representation (clustering used %d)."
* Sweep-Line-Algorithmus pro Cluster (`.sweep_line_representative()` in sweep_line.R, basiert auf Paper Figure 15):
  1. **Average Direction Vector:** Berechnet durch Summieren der rohen (nicht-normalisierten) Richtungsvektoren (ex-sx, ey-sy) aller Segmente im Cluster, dann Normalisierung auf Einheitslänge. Längere Segmente tragen proportional mehr zur Clusterrichtung bei (Paper Definition 11). Guard-Clause: Wenn ||unnormalisierter Summenvektor|| < 1e-15 (Segmente heben sich gegenseitig auf), wird auf die X-Achse c(1, 0) als Fallback-Richtung zurückgegriffen und eine warning() ausgegeben.
  2. **Bei coord_type = "geographic":** Segmentkoordinaten werden vor dem gesamten Algorithmus lokal equirectangular projiziert und auf Meter skaliert: x' = lon × cos(lat_mean) × 111320, y' = lat × 111320. Bei method = "haversine": per-Cluster lat_mean = mean(c(sy, ey)). Bei method = "projected": globaler proj_params$lat_mean.
  3. **Achsenrotation:** Koordinaten werden so rotiert (`.rotate_to_axis()`), dass die X'-Achse parallel zum Average Direction Vector liegt (Paper Formula 9). Rücktransformation via `.rotate_from_axis()`.
  4. **Segmentnormalisierung:** Für jedes Segment nach Rotation: left_x = min(sx', ex'), right_x = max(sx', ex'). Y-Werte werden korrekt dem left/right zugeordnet. Segmente die gegen die Hauptrichtung zeigen werden so normalisiert dass left_x < right_x.
<!-- NEU -->
  4b. **Zero-Length-Segment-Filter:** Segmente mit Länge < 1e-15 im rotierten System werden vor dem Sweep gefiltert, um Division durch Null bei der Y-Interpolation zu verhindern.
  5. **Event-Sortierung:** Zwei Arten von Events: Segment-Entry (bei left_x, inkrementiert den Sweep-Zähler) und Segment-Exit (bei right_x, dekrementiert den Sweep-Zähler). Alle Events werden nach X'-Position sortiert. Tie-Breaking: `order(event_x, -event_type)` — bei gleichem X'-Wert werden Entry-Events (1) vor Exit-Events (-1) verarbeitet — das maximiert den Segmentzähler an jeder Position.
  6. **Sweep:** An jeder Event-Position wird die Anzahl kreuzender Segmente gezählt. Ein Waypoint wird nur generiert wenn: (a) Anzahl kreuzender Segmente ≥ min_lns, **(b) mindestens 2 verschiedene Trajektorien unter den aktiven Segmenten vertreten sind** (Trajectory-Diversity-Check, `n_distinct_traj >= 2`, siehe unten), und (c) X'-Abstand zum **letzten generierten Waypoint** (nicht zum letzten Event-Point) ≥ gamma (`cur_x - last_wp_x >= gamma`, `last_wp_x` wird nur bei Waypoint-Generierung aktualisiert). Der Y'-Wert des Waypoints ist der Mittelwert der **linear interpolierten** Y'-Koordinaten aller kreuzenden Segmente an der aktuellen X'-Position: `t_vals = (cur_x - left_x) / seg_len`, `y_interp = left_y + t_vals * (right_y - left_y)`.
  7. **Rücktransformation:** Waypoints werden zurückrotiert und (bei geographic) zurück in Lon/Lat transformiert.

**Abweichung vom Paper: Trajectory-Diversity-Check in der Sweep-Line (F1)**

Das Paper (Figure 15, Line 06) zählt in der Sweep-Line ausschließlich die Anzahl kreuzender *Segmente* (`nump`). Unsere Implementierung fügt eine zusätzliche Bedingung hinzu: An jeder Waypoint-Position müssen mindestens **2 verschiedene Trajektorien** unter den aktiven Segmenten vertreten sein (`n_distinct_traj >= 2`).

*Grund:* Durch das Entry-Before-Exit Tie-Breaking (Punkt 5) werden bei gleichem X'-Wert Entry-Events vor Exit-Events verarbeitet. Wenn zwei aufeinanderfolgende Segmente *derselben Trajektorie* einen Characteristic Point teilen (das Ende von Segment k und der Anfang von Segment k+1 haben denselben X'-Wert), steigt der Segmentzähler an diesem Punkt momentan um 1 — das neue Segment wird aktiviert bevor das alte deaktiviert wird. Bei `min_lns = 2` reicht dieser momentane Peak aus, um einen Waypoint zu generieren. Drei oder mehr konsekutive Segmente derselben Trajektorie erzeugen so ≥ 2 Waypoints, und die resultierende Representative zeichnet den Pfad einer einzelnen Trajektorie nach — das widerspricht dem Ziel des Algorithmus, *gemeinsame* Sub-Trajektorien aus *verschiedenen* Trajektorien zu finden.

Alle Paper-Experimente verwenden MinLns = 6–9 (Section 4.4: "optimal MinLns as avg|Nε(L)| + 1~3"), wo dieser Edge Case praktisch nicht auftritt. Keine der existierenden TRACLUS-Implementierungen (Python, Java, R/C++) adressiert dieses Problem.

*Lösung:* Die Original-Prüfung `count >= min_lns` (Segmentdichte, Paper-konform) bleibt erhalten. Die zusätzliche Bedingung `n_distinct_traj >= 2` eliminiert nur den degenerierten Fall (Single-Trajectory-Peaks an Berührungspunkten). Bei `min_lns >= 3` ändert sich das Verhalten in der Praxis nicht, da an Berührungspunkten konsekutiver Segmente der momentane Peak maximal 2 beträgt und damit unter dem Threshold liegt. Die Erweiterung ist konsistent mit dem Cardinality-Check in Phase 2, der ebenfalls Trajektorien-Diversität prüft.
* Cluster mit < 2 resultierenden Waypoints werden zu Noise degradiert (`if (wp_count < 2L) return(NULL)` in `.sweep_line_representative()`). Repräsentative Trajektorien können räumliche Sprünge enthalten wenn die Segmentdichte innerhalb eines Clusters unter min_lns fällt und dann wieder ansteigt. Dies ist inhärent zum Sweep-Line-Algorithmus und tritt bei Clustern mit internen Dichtelücken auf. Representatives sollten als geordnete Waypoint-Sequenzen interpretiert werden, nicht als stetige Pfade.
* Fehlgeschlagene Representatives: tc_represent() erstellt eine eigene segments-Kopie mit aktualisierten cluster_ids (renummeriert, fehlgeschlagene Cluster zu Noise). Die Referenz auf das tc_clusters-Objekt bleibt unverändert und enthält die Prä-Cleanup-IDs — so ist die Transformation nachvollziehbar. Zähler (n_clusters, n_noise) werden aktualisiert. message() gibt aus wie viele Cluster verloren gingen.
* Bei 0 Clustern im Input: warning() ausgeben, leeres tc_representatives-Objekt zurückgeben. Kein stop().
* Rückgabe: tc_representatives-Objekt mit representatives data.frame (Spalten: cluster_id, point_id, rx, ry)
* plot(ergebnis) / tc_leaflet(ergebnis)

**Schritt 5: Wrapper**
* tc_traclus(x, eps, min_lns, gamma = 1, repr_min_lns = NULL, w_perp = 1, w_par = 1, w_angle = 1, verbose = TRUE) — vereint alle drei Berechnungsschritte
* Erstes Argument: tc_trajectories-Objekt (Klassenprüfung via `.check_class()`, stop() bei falschem Typ: "Expected a 'tc_trajectories' object. Run tc_trajectories() first.")
* eps und min_lns: Pflichtparameter ohne Defaults, Prüfung via missing() mit custom Fehlermeldung (identisch zu tc_cluster). Parametervalidierung wie bei tc_cluster() und tc_represent() — Fail-early vor tc_partition-Aufruf.
* gamma hat Default 1, konsistent mit tc_represent().
* min_lns wird konsistent für Clustering und Repräsentation verwendet (Paper-Default). repr_min_lns optional für Power-User — überschreibt min_lns nur für die Repräsentation. Dokumentation: "repr_min_lns corresponds to the min_lns parameter of tc_represent(). If NULL (default), the clustering min_lns is used for both phases."
* Alle weiteren Parameter durchreichbar (Gewichte)
* tc_traclus() reicht seinen verbose-Parameter an alle drei internen Funktionsaufrufe (tc_partition, tc_cluster, tc_represent) durch. Keine zusätzlichen Wrapper-Level-Messages werden generiert.
* Rückgabe: Objekt mit class = c("tc_traclus", "tc_representatives"). Erbt alle Methoden von tc_representatives (plot via `NextMethod()`, tc_leaflet via `NextMethod()`), die Referenzkette bleibt intakt.
* plot(ergebnis) / tc_leaflet(ergebnis) — erbt von tc_representatives via S3-Dispatch

<!-- NEU -->
**Interne Hilfsfunktionen:**

* `.check_class(x, expected_class, function_name)` — Zentrale Klassenprüfung für Workflow-Funktionen. Fehlermeldung: "Expected a '{expected_class}' object. Run {function_name}() first."
* `.validate_eps()`, `.validate_min_lns()`, `.validate_gamma()`, `.validate_weights()` — Parametervalidierung in validators.R
* `.merge_plot_args()` — Parst ...-Argumente für Plot-Methoden, verhindert Konflikte mit hartcodierten Parametern
* `.truncate_ids(max_show = 5)` — Kürzt ID-Listen in Warnungen
* `.check_antimeridian()` — Prüft auf Antimeridian-Kreuzungen in Trajektorien
* `.group_by_traj_id()` — Gruppiert Daten nach traj_id, bewahrt Originalreihenfolge
* `.resolve_method()` — Löst method basierend auf coord_type auf (6 Kombinationen)
* `.r_swap_segments()` / `.r_swap_segments_sph()` — Swap-Konvention für Distanzfunktionen
* `.compute_asp()` — Berechnet Aspect Ratio für Plots
* `.rotate_to_axis()` / `.rotate_from_axis()` — Achsenrotation für Sweep-Line (Paper Formula 9)
* `.sweep_line_representative()` — Sweep-Line-Algorithmus pro Cluster
* `.dbscan_expand()` — DBSCAN-Expansionslogik
* `.renumber_clusters()` — Lückenlose Cluster-ID-Renummerierung
