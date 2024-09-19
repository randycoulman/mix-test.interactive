# mix test.interactive

[![Build
Status](https://github.com/randycoulman/mix_test_interactive/actions/workflows/ci.yml/badge.svg)](https://github.com/randycoulman/mix_test_interactive/actions)
[![Module
Version](https://img.shields.io/hexpm/v/mix_test_interactive.svg)](https://hex.pm/packages/mix_test_interactive)
[![Hex
Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/mix_test_interactive/)
[![License](https://img.shields.io/hexpm/l/mix_test_interactive.svg)](https://github.com/randycoulman/mix_test_interactive/blob/master/LICENSE.md)

`mix test.interactive` is an interactive test runner for ExUnit tests.

Based on Louis Pilfold's wonderful
[mix-test.watch](https://github.com/lpil/mix-test.watch) and inspired by Jest's
interactive watch mode, `mix test.interactive` allows you to dynamically change
which tests should be run with a few keystrokes.

It allows you to easily switch between running all tests, stale tests, or failed
tests. Or, you can run only the tests whose filenames contain a substring.
Includes an optional "watch mode" which runs tests after every file change.

## Installation

The package can be installed by adding `mix_test_interactive` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mix_test_interactive, "~> 4.0", only: :dev, runtime: false}
  ]
end
```

## Usage

```shell
mix test.interactive <options> [-- <mix test arguments>]
mix test.interactive <mix test arguments>
mix test.interactive --help
mix test.interactive --version
```

Your tests will run immediately (and every time a file changes).

### Options

`mix test.interactive` understands the following options, most of which
correspond to configuration settings below.

Note that, if you want to pass both mix test.interactive options and mix test
arguments, you must separate them with `--`.

If an option is provided on the command line, it will override the same option
specified in the configuration.

- `--(no-)clear`: Clear the console before each run (default `false`).
- `--command <command> [--arg <arg>]`: Custom command and arguments for running
  tests (default: "mix" with no arguments). NOTE: Use `--arg` multiple times to
  specify more than one argument.
- `--exclude <regex>`: Exclude files/directories from triggering test runs
  (default: `["~r/\.#/", "~r{priv/repo/migrations}"`]) NOTE: Use `--exclude`
  multiple times to specify more than one regex.
- `--extra-extensions <extension>`: Watch files with additional extensions
  (default: []).
- `--runner <module name>`: Use a custom runner module (default:
  `MixTestInteractive.PortRunner`).
- `--task <task name>`: Run a different mix task (default: `"test"`).
- `--(no-)timestamp`: Display the current time before running the tests
  (default: `false`).
- `--(no-)watch`: Don't run tests when a file changes (default: `true`).

All of the `<mix test arguments>` are passed through to `mix test` on every test
run.

`mix test.interactive` will detect the `--failed`, `--seed`, and `--stale`
options and use those as initial settings in interactive mode. You can then use
the interactive mode commands to adjust those options as needed. It will also
detect any filename or pattern arguments and use those as initial settings.
However, it does not detect any filenames passed with `--include` or `--only`.
Note that if you specify a pattern on the command-line, `mix test.interactive`
will find all test files matching that pattern and pass those to `mix test` as
if you had used the `p` command.

### Patterns and filenames

`mix test.interactive` can take the same filename or filename:line_number
patterns that `mix test` understands. It also allows you to specify one or more
"patterns" - strings that match one or more test files. When you provide one or
more patterns on the command-line, `mix test.interactive` will find all test
files matching those patterns and pass them to `mix test` as if you had used the
`p` command (described below).

After the tests run, you can use the interactive mode to change which tests will
run.

Use the `p` command to run only test files that match one or more provided
patterns. A pattern is the project-root-relative path to a test file (with or
without a line number specification) or a string that matches a portion of full
pathname. e.g. `test/my_project/my_test.exs`,
`test/my_project/my_test.exs:12:24` or `my`.

Any patterns that contain a line number specification are passed directly to
`mix test`. Remaining patterns are matched against test filenames as above.

```
p pattern1 pattern2
```

Use the `s` command to run only test files that reference modules that have
changed since the last run (equivalent to the `--stale` option of `mix test`).

Use the `f` command to run only tests that failed on the last run (equivalent to
the `--failed` option of `mix test`).

Use the `a` command to run all tests, turning off the `--failed` and `--stale`
flags as well as clearing any patterns.

Use the `d <seed>` command to run tests with a specific seed, and then use `d`
(with no seed) to remove the seed.

Use the `w` command to turn file-watching mode on or off.

Use the `Enter` key to re-run the current set of tests without requiring a file
change.

Use the `q` command, or press `Ctrl-D` to exit the program.

## Configuration

`mix test.interactive` can be configured with various options using application
configuration. You can also use command line arguments to specify these
configuration options, or to override configured options.

### `clear`: Clear the console before each run

If you want `mix test.interactive` to clear the console before each run, you can
enable this option in your config/dev.exs as follows:

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    clear: true
end
```

### `command`: Use a custom command

By default, `mix test.interactive` uses `mix test` to run tests.

You might want to provide a custom command that does other things before or
after running `mix`. In that case, you can customize the command used for
running tests.

For example, you might want to provide a name for the test runner process to
allow connection from other Erlang nodes. Or you might want to run other
commands before or after running the tests.

In those cases, you can customize the command that `mix test.interactive` will
use to run your tests. `mix test.interactive` assumes that the custom command
ultimately runs `mix` under the hood (or at least accepts all of the same
command-line arguments as `mix`). The custom command can either be a string or a
`{command, [..args..]}` tuple.

Examples:

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    command: "path/to/my/test_runner.sh"
end
```

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    command: {"elixir", ["--sname", "name", "-S", "mix"]}
end
```

To run a different mix task instead, see the `task` option below.

### `exclude`: Excluding files or directories

To stop changes to specific files or directories from triggering test runs, you
can add `exclude:` regexp patterns to your config in `mix.exs`:

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    exclude: [~r/db_migration\/.*/,
              ~r/useless_.*\.exs/]
end
```

The default is `exclude: [~r/\.#/, ~r{priv/repo/migrations}]`.

### `extra_extensions`: Watch files with additional extensions

By default, `mix test.interactive` will trigger a test run when a known Elixir
or Erlang file has changed, but not when any other file changes.

You can specify additional file extensions to be included with the
`extra_extensions` option.

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    extra_extensions: ["json"]
end
```

`mix test.interactive` always watches files with the following extensions:
`.erl`, `.ex`, `.exs`, `.eex`, `.leex`, `.heex`, `.xrl`, `.yrl`, and `.hrl`. To
ignore files with any of these extensions, you can specify an `exclude` regexp
(see above).

### `runner`: Use a custom runner module

By default `mix test.interactive` uses an internal module named
`MixTestInteractive.PortRunner` to run the tests. If you want to run the tests
in a different way, you can supply your own runner module instead. Your module
must implement a `run/2` function that takes a `MixTestInteractive.Config`
struct and a list of `String.t()` arguments.

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    runner: MyApp.FancyTestRunner
end
```

### `task`: Run a different mix task

By default, `mix test.interactive` runs `mix test`.

Through the mix config it is possible to run a different mix task. `mix
test.interactive` assumes that this alternative task accepts the same
command-line arguments as `mix test`.

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    task: "custom_test_task"
end
```

The task is run with `MIX_ENV` set to `test`.

To use a custom command instead, see the `command` option above.

### `timestamp`: Display the current time before running the tests

When `timestamp` is set to true, `mix test.interactive` will display the current
time (UTC) just before running the tests.

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    timestamp: true
end
```

## Compatibility Notes

On Linux you may need to install `inotify-tools`.

## Desktop Notifications

You can enable desktop notifications with
[ex_unit_notifier](https://github.com/navinpeiris/ex_unit_notifier).

## Acknowledgements

This project started as a clone of the wonderful
[mix-test.watch](https://github.com/lpil/mix-test.watch) project, which I've
used and loved for years. I've added the interactive mode features to the
existing feature set.

The idea for having an interactive mode comes from [Jest](https://jestjs.io/)
and its incredibly useful interactive watch mode.

## Copyright and License

Copyright (c) 2021-2024 Randy Coulman

This work is free. You can redistribute it and/or modify it under the terms of
the MIT License. See the [LICENSE.md](./LICENSE.md) file for more details.
