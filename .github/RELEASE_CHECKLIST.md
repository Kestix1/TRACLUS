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
- [ ] r-hub check on Fedora/GCC + Debian/Clang + Windows UCRT (`rhub.yaml`)
- [ ] `devtools::check_win_devel()` submitted and result reviewed

## 6. Submission

- [ ] `devtools::release()` (interactive checklist + upload) **or** manual upload at https://cran.r-project.org/submit.html
- [ ] CRAN confirmation email received
- [ ] Monitor CRAN incoming checks for 1–3 days; respond to any reviewer feedback within 48 h

## 7. Post-Acceptance

- [ ] Create a GitHub Release (tag: `v<version>`, body from `NEWS.md`) — automated via `release.yaml` on tag push
- [ ] Update `cran-comments.md` with acceptance date
- [ ] Bump version to next development version (e.g., `1.0.0.9000`)

---

## 8. Post-CRAN (activate when relevant)

- [ ] **Valgrind** — run `valgrind.yaml` manually (`workflow_dispatch`) once after ASAN/UBSAN is green; too slow for push triggers
- [ ] **fledge** — activate after first patch release: `usethis::use_package("fledge", type = "Suggests")` + `fledge::fledge()`; automates `NEWS.md` + version bump from Conventional Commits
- [ ] **revdepcheck** — run `revdepcheck::revdep_check()` once downstream packages start depending on TRACLUS
