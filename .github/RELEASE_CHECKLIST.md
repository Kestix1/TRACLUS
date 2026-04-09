# CRAN Release Checklist

Step-by-step process before submitting to CRAN. Complete every item in order.

---

## 1. Code Quality

- [ ] All `R CMD check` warnings resolved (ubuntu/release must be 0 errors | 0 warnings)
- [ ] `lintr::lint_package()` returns no linting errors
- [ ] No `TODO`, `FIXME`, or `browser()` calls left in source code
- [ ] No `print()` or `cat()` debug statements left in R/ code

## 2. Tests

- [ ] `devtools::test()` passes with 0 failures, 0 errors, 0 skipped (unexpectedly)
- [ ] Test coverage ≥ 80% (check at Codecov or `covr::package_coverage()`)
- [ ] New features / bug fixes have corresponding tests

## 3. Documentation

- [ ] All exported functions have `@examples` (or `\dontrun{}` with justification)
- [ ] `devtools::document()` run — no Rd warnings
- [ ] `devtools::spell_check()` returns 0 typos (update `inst/WORDLIST` if needed)
- [ ] `urlchecker::url_check()` returns 0 broken URLs
- [ ] `NEWS.md` updated with changes since last release
- [ ] `cran-comments.md` updated with current test environments and results

## 4. DESCRIPTION

- [ ] `Version` bumped appropriately (patch / minor / major)
- [ ] `Date` field updated (if present)
- [ ] All new dependencies listed under `Imports` / `Suggests`
- [ ] `BugReports` and `URL` fields are valid and reachable

## 5. CI / Platform Checks

- [ ] GitHub Actions R-CMD-check green on all 5 matrix jobs
- [ ] ASAN/UBSAN workflow (`asan.yaml`) passes — **mandatory for Rcpp packages**
- [ ] r-hub check green (see below)
- [ ] Valgrind check green (see below)
- [ ] `devtools::check_win_devel()` submitted and result reviewed (see below)

### How to run the manual platform checks

**r-hub** (tests on Fedora/GCC, Debian/Clang, Windows UCRT):

```
Option A — GitHub UI (recommended):
  Repo → Actions → R-hub → Run workflow → Run

Option B — R console (recommended platforms for CRAN submission):
  rhub::rhub_check()
  # Select platforms: 1, 4, 5, 6, 8, 18, 33
  #   1  = linux          (Ubuntu, R release)
  #   4  = macos          (macOS, R release)
  #   5  = macos-arm64    (Apple Silicon, R release)
  #   6  = windows        (Windows, R release)
  #   8  = atlas          (Linux, ATLAS BLAS/LAPACK)
  #  18  = clang-asan     (Linux, clang + AddressSanitizer)
  #  33  = gcc14          (Linux, GCC 14)
```

**Valgrind** (memory error check, ~30–60 min):

```
GitHub UI → Actions → valgrind → Run workflow → Run
→ wait for green; on failure: download the artifact and inspect the log
```

**WinBuilder** (CRAN's own Windows server with R-devel, ~1 h turnaround):

```r
devtools::check_win_devel()
# → submits the package and sends results to m.hoblisch@gmail.com
# → wait for the email before submitting to CRAN
```

## 6. Submission

- [ ] `devtools::release()` (interactive checklist + upload) **or** manual upload at https://cran.r-project.org/submit.html
- [ ] CRAN confirmation email received
- [ ] Monitor CRAN incoming checks for 1–3 days; respond to any reviewer feedback within 48 h

## 7. Post-Acceptance

- [ ] Push a version tag to trigger the automated GitHub Release:

```bash
git tag v1.x.x
git push origin v1.x.x
# release.yaml runs automatically and creates a GitHub Release from NEWS.md
```

- [ ] Update `cran-comments.md` with acceptance date
- [ ] Bump to the next development version:

```r
usethis::use_dev_version()
# sets Version to 1.x.x.9000 in DESCRIPTION
```

- [ ] Commit the version bump:

```
chore: bump to development version 1.x.x.9000
```

---

## 8. CI-Workflows reaktivieren (vor CRAN-Submission)

Diese Workflows wurden während der Entwicklung mit privaten Repo-Einschränkungen
temporär abgeschwächt. Vor der Submission vollständig reaktivieren:

- [ ] **`scorecard.yaml`** — `continue-on-error: true` auf `false` setzen UND
  `publish_results: false` auf `true` setzen (Scorecard benötigt öffentliches Repo
  für GraphQL-Zugriff und zum Publizieren der Ergebnisse)

- [ ] **`spelling.yaml`** — Prüfen ob Spell-Check Fehler tatsächlich den CI
  abbricht (aktuell: `spell_check_package()` gibt nur DataFrame zurück, bricht
  nicht ab). Ggf. durch Wrapper ersetzen:
  ```r
  res <- spelling::spell_check_package()
  if (nrow(res) > 0) stop(paste("Spelling errors:", paste(res$word, collapse = ", ")))
  ```

- [ ] **`test-coverage.yaml`** — `CODECOV_TOKEN`-Secret in GitHub Repo-Settings
  hinterlegen (Settings → Secrets → Actions) und `fail_ci_if_error: false` auf
  `true` setzen, damit Coverage-Upload wieder blockiert bei Fehler

- [ ] **`asan.yaml`** — `_R_CHECK_FORCE_SUGGESTS_: false` evaluieren: prufen ob
  `leaflet`, `sf` im `wch1/r-debug`-Container installierbar sind; falls ja,
  Variable entfernen damit suggested packages ebenfalls unter ASAN getestet werden

---

## 9. Post-CRAN (activate when relevant)

- [ ] **Valgrind** — run `valgrind.yaml` manually (`workflow_dispatch`) once after ASAN/UBSAN is green; too slow for push triggers
- [ ] **fledge** — activate after first patch release: `usethis::use_package("fledge", type = "Suggests")` + `fledge::fledge()`; automates `NEWS.md` + version bump from Conventional Commits
- [ ] **revdepcheck** — run `revdepcheck::revdep_check()` once downstream packages start depending on TRACLUS
