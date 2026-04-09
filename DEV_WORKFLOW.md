# Development Workflow

Day-to-day guide for working on TRACLUS after the initial CRAN release.
**TL;DR:** Run `devtools::document()`, update `NEWS.md`, then push — the
rest is automated.

------------------------------------------------------------------------

## A. What runs automatically — nothing to do

### On every `git commit` (pre-commit hooks, local)

| Hook                   | What it catches                                                |
|------------------------|----------------------------------------------------------------|
| `parseable-R`          | R syntax errors                                                |
| `no-browser-statement` | stray [`browser()`](https://rdrr.io/r/base/browser.html) calls |
| `no-debug-statement`   | stray [`debug()`](https://rdrr.io/r/base/debug.html) calls     |
| `deps-in-desc`         | packages used but not listed in `DESCRIPTION`                  |
| `lintr`                | code style violations                                          |

The commit is **blocked** if any hook fails. Fix the issue and
re-commit.

### On every push / pull request (GitHub Actions)

| Workflow        | What it checks                                                 |
|-----------------|----------------------------------------------------------------|
| `R-CMD-check`   | 5 platforms: macOS, Windows, Ubuntu devel / release / oldrel-1 |
| `asan`          | ASAN + UBSAN memory errors in the C++ backend                  |
| `lint`          | lintr (full package)                                           |
| `spelling`      | spell check across all Rd, vignettes, README                   |
| `urlchecker`    | all URLs in Rd, DESCRIPTION, README                            |
| `test-coverage` | Codecov — project ≥ 80%, patch ≥ 70%                           |
| `pkgdown`       | documentation site rebuild                                     |

You do **not** need to run any of these locally before pushing.

------------------------------------------------------------------------

## B. Before every commit — required

**1. Regenerate documentation** (whenever any roxygen2 comment changed):

``` r
devtools::document()
```

Forgetting this causes stale `.Rd` files and will create a diff on the
next `devtools::document()` run.

**2. Update `NEWS.md`** for any user-facing change:

``` md
# TRACLUS (development version)

* Brief description of the change.
```

------------------------------------------------------------------------

## C. Before every commit — recommended

**Run the test suite locally** to catch failures before waiting for CI:

``` r
devtools::test()
```

------------------------------------------------------------------------

## D. Special cases

### Adding a new dependency

``` r
usethis::use_package("pkg")               # adds to Imports
usethis::use_package("pkg", "Suggests")   # adds to Suggests
```

> The `deps-in-desc` pre-commit hook will block the commit if a package
> is used in the code but not yet listed in `DESCRIPTION`.

### Changing C++ code (`src/`)

Run a full local check before pushing — the ASAN workflow takes ~10 min:

``` r
devtools::check(args = "--as-cran")
```

After pushing, keep an eye on the `asan` workflow in GitHub Actions.

### Snapshot tests are out of date

After intentional output or visual changes, update the snapshots:

``` r
# vdiffr SVG snapshots (plot methods):
vdiffr::manage_cases()

# testthat text snapshots (print / summary output):
testthat::snapshot_review()
```

Commit the updated snapshot files alongside your code change.

### Updating `codemeta.json`

After bumping the version or changing `DESCRIPTION` metadata,
regenerate:

``` r
# requires the codemetar package (not in Suggests — install once locally):
# install.packages("codemetar")
codemetar::write_codemeta()
```

------------------------------------------------------------------------

## E. What you do NOT need to do manually

| Task                                          | Why not needed                                                                                                                     |
|-----------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| Run lintr                                     | pre-commit hook + `lint` CI workflow                                                                                               |
| Run spell check                               | `spelling` CI workflow                                                                                                             |
| Check URLs                                    | `urlchecker` CI workflow                                                                                                           |
| Platform checks (r-hub, Valgrind, WinBuilder) | Only needed before a CRAN submission — see [`RELEASE_CHECKLIST.md`](https://martinhoblisch.github.io/TRACLUS/RELEASE_CHECKLIST.md) |
| Rebuild pkgdown site                          | `pkgdown` CI workflow                                                                                                              |

------------------------------------------------------------------------

## F. Ready to release?

Follow the full step-by-step process in
[`RELEASE_CHECKLIST.md`](https://martinhoblisch.github.io/TRACLUS/RELEASE_CHECKLIST.md).
