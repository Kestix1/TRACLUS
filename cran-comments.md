# CRAN Submission Comments

## Test environments

- Local: Windows 10 (build 19045), R 4.4.3
- GitHub Actions: ubuntu-latest (R release, R devel), macOS-latest (R release),
  windows-latest (R release), ubuntu-latest (R oldrel-1)
- r-hub: windows-latest (R devel), ubuntu-gcc-devel, ubuntu-clang-devel,
  ubuntu-next, fedora-clang-devel, debian-clang-devel, macos-arm64-next

## R CMD check results

0 errors | 0 warnings | 2 notes

## Notes for CRAN reviewers

* This is a new submission.

* The package implements the TRACLUS trajectory clustering algorithm
  (Lee, Han & Whang, 2007, doi:10.1145/1247480.1247546).
  C++ code via Rcpp is included for performance-critical distance calculations.
  ASAN/UBSAN checks have been run with the rocker/r-devel-san image —
  no memory errors detected.

* NOTE: installed size is 7.1 Mb (sub-directories: doc 3.0 Mb, extdata 2.7 Mb,
  libs 1.0 Mb).
  - `inst/extdata/hurdat2_1950_2004.txt` (2.7 Mb) is the HURDAT2 Atlantic
    hurricane best-track database (1950–2004, NOAA). It is required for
    `tc_read_hurdat2()` and the geographic vignette; no smaller substitute
    preserves the illustrative value of real storm tracks.
  - The 3.0 Mb doc/ directory consists of pre-built vignette HTML files;
    this is unavoidable with `VignetteBuilder: knitr`.
  - The 1.0 Mb libs/ directory contains the compiled Rcpp shared library.

* NOTE: new submission (expected for a first CRAN submission).

## Reverse dependencies

None (new package).
