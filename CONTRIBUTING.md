# Contributing to TRACLUS

Thank you for considering a contribution to TRACLUS! This document describes how
you can help — from filing a bug report to submitting a pull request.

---

## Code of Conduct

Please note that this project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this
project you agree to abide by its terms.

---

## How to contribute

### Bug reports

Use the [GitHub issue tracker](https://github.com/MartinHoblisch/TRACLUS/issues)
and choose the **Bug report** template. Please include:

- Your R version (`R.version.string`)
- Your TRACLUS version (`packageVersion("TRACLUS")`)
- Your operating system
- A **minimal reproducible example** (see the
  [`reprex`](https://reprex.tidyverse.org/) package for help creating one)
- The full error message / traceback

### Feature requests

Open an issue and choose the **Feature request** template. Describe the problem
you want to solve and why the existing interface does not cover it.

### Pull requests

1. **Fork** the repository and create a feature branch from `master`:
   ```
   git checkout -b feature/my-improvement
   ```

2. **Install development dependencies:**
   ```r
   install.packages(c("devtools", "roxygen2", "testthat", "styler", "lintr"))
   devtools::install_deps(dependencies = TRUE)
   ```

3. **Write tests first.** New behaviour must be covered by tests in
   `tests/testthat/`. Run the test suite before committing:
   ```r
   devtools::test()
   ```

4. **Follow the coding style.** Run the formatter and linter:
   ```r
   styler::style_pkg()
   lintr::lint_package()
   ```

5. **Document all exported functions** with
   [roxygen2](https://roxygen2.r-lib.org/) and regenerate the documentation:
   ```r
   devtools::document()
   ```

6. **Run a full package check** to make sure no new warnings or notes appear:
   ```r
   devtools::check(args = "--as-cran")
   ```

7. **Update `NEWS.md`** with a brief description of the change under the
   `# TRACLUS (development version)` heading.

8. Open a pull request against `master`. The CI workflows will run
   automatically.

---

## Style guide

- Code: follow the
  [Tidyverse style guide](https://style.tidyverse.org/) — `styler` enforces
  most of this automatically.
- Documentation: use roxygen2 Markdown syntax. All exported functions need
  `@param`, `@return`, and `@examples`.
- Commit messages: use the
  [Conventional Commits](https://www.conventionalcommits.org/) format
  (`feat:`, `fix:`, `docs:`, `test:`, `chore:`, `ci:`).

---

## Questions

If you have a question about how to use TRACLUS, please open a
[GitHub Discussion](https://github.com/MartinHoblisch/TRACLUS/discussions) or
check the [package documentation](https://martinhoblisch.github.io/TRACLUS/).
