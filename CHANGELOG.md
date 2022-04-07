# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/influxdata/mix_test_interactive/compare/v1.2.0...HEAD)

## [v1.2.0](https://github.com/influxdata/mix_test_interactive/compare/v1.1.0...v1.2.0)

### Changed

- Now tested against Elixir 1.12 and 1.13. ([#55](https://github.com/influxdata/mix_test_interactive/pull/55))
- Misc. dependency upgrades. ([#55](https://github.com/influxdata/mix_test_interactive/pull/55))

### Documentation

- Include proper source ref in the generated documentation so that it now points at the correct version of the source code. ([#51](https://github.com/influxdata/mix_test_interactive/pull/51) - Thanks @kianmeng!)

- Include license and changelog in generated documentation. ([#51](https://github.com/influxdata/mix_test_interactive/pull/51) - Thanks @kianmeng!)

## [v1.1.0](https://github.com/influxdata/mix_test_interactive/compare/v1.0.1...v1.1.0)

### Fixed

- The `p` (pattern) command now works properly in umbrella projects. Previously, it was unable to find any test files in order to filter the pattern and would therefore not run any tests. Now, in an umbrella project, `mix test.interactive` looks for test files in `apps/*/test` by default, but still respects the `:test_paths` config option used by `mix test`. ([#48](https://github.com/influxdata/mix_test_interactive/pull/48))

### Documentation

- Fixed the spelling of Louis Pilfold's name in the README. Sorry, Louis! 🤦‍♂️ ([#49](https://github.com/influxdata/mix_test_interactive/pull/49))

## [v1.0.1](https://github.com/influxdata/mix_test_interactive/compare/v1.0.0...v1.0.1)

### Fixed

- Eliminates a GenServer call timeout that can occur if a command is typed while a long-running test run is in progress. ([#44](https://github.com/influxdata/mix_test_interactive/pull/44)).

## [v1.0.0](https://github.com/influxdata/mix_test_interactive/compare/14eb50c742a042de7bfc37c41b8af68d839eb443...v1.0.0)

🎉 Happy Birthday!

The following sections describe changes from [mix-test.watch](https://github.com/lpil/mix-test.watch), which served as the basis of this project.

### Added

- Interactive mode allows dynamically filtering test files based on a substring pattern or switching to run only failed or stale tests without having to restart.

- File-watching mode can be turned on and off, either by passing `--no-watch` on the command line, or by using the `w` command to dynamically toggle watch mode on and off. When file-watching mode is on, tests will be run in response to file changes as with `mix-test.watch`. When off, tests must be run explicitly using the `Enter` key or by using another command that changes the set of tests to be run.

### Removed

- It is no longer possible to customize the CLI executable. We always use `mix`. Previously, this allowed the use of `iex -S mix` instead, but that doesn't work well with interactive mode.

- It is no longer possible to specify multiple tasks to run on file changes. This ability added complexity and the feature didn't work very well because it assumed that all tasks would take the exact same set of command-line arguments. It is still possible to specify a different task name than `test`, but `mix test.interactive` assumes that the custom task accepts the same command-line arguments as `mix test`.

### Fixed

- On Windows, `mix test.interactive` runs the correct `mix` task, including a custom task provided in the configuration, rather than always running `mix test`. It also passes along other provided command-line arguments as well as those injected by `mix test.interactive`.
