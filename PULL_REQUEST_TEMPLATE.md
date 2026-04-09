# NA

## Description

## Checklist

`R CMD check` is green (0 errors, 0 warnings on ubuntu/release)

All new and existing tests pass (`devtools::test()`)

New behaviour is covered by tests

`NEWS.md` updated (for any user-facing change)

Documentation regenerated (`devtools::document()`)

`DESCRIPTION` `Imports`/`Suggests` updated (if new dependencies were
added)

No debug code left behind
([`browser()`](https://rdrr.io/r/base/browser.html),
[`print()`](https://rdrr.io/r/base/print.html),
[`cat()`](https://rdrr.io/r/base/cat.html))

ASAN workflow is green (required for any change to `src/`)
