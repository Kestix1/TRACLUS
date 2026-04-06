# CRAN Submission Comments

## Test environments

- Local: Windows 10, R 4.x.x
- GitHub Actions: ubuntu-latest (R release, R devel), macOS-latest (R release), windows-latest (R release), ubuntu-latest (R oldrel-1)
- r-hub: Fedora Linux / GCC, Debian Linux / Clang, Windows / UCRT

## R CMD check results

0 errors | 0 warnings | 0 notes

## Notes for CRAN reviewers

* This is a new submission.
* The package implements the TRACLUS trajectory clustering algorithm (Lee, Han & Whang, 2007, doi:10.1145/1247480.1247546).
* C++ code via Rcpp is included for performance-critical distance calculations.
* ASAN/UBSAN checks have been run with the rocker/r-devel-san image — no memory errors detected.

## Reverse dependencies

None (new package).
