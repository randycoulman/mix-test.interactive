defmodule MixTestInteractive.SettingsTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.Settings

  describe "filtering test files" do
    test "filters to files matching patterns" do
      all_files = ~w(file1 file2 no_match other)

      settings =
        %Settings{initial_cli_args: ["--trace"]}
        |> with_fake_file_list(all_files)
        |> Settings.only_patterns(["file", "other"])

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "file1", "file2", "other"]
    end

    test "returns error if no files match pattern" do
      settings =
        %Settings{}
        |> with_fake_file_list([])
        |> Settings.only_patterns(["file"])

      assert {:error, :no_matching_files} = Settings.cli_args(settings)
    end

    test "restricts to failed tests" do
      settings =
        Settings.only_failed(%Settings{initial_cli_args: ["--trace"]})

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "--failed"]
    end

    test "restricts to stale tests" do
      settings =
        Settings.only_stale(%Settings{initial_cli_args: ["--trace"]})

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "--stale"]
    end

    test "pattern filter clears failed flag" do
      settings =
        %Settings{}
        |> with_fake_file_list(["file"])
        |> Settings.only_failed()
        |> Settings.only_patterns(["f"])

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["file"]
    end

    test "pattern filter clears stale flag" do
      settings =
        %Settings{}
        |> with_fake_file_list(["file"])
        |> Settings.only_stale()
        |> Settings.only_patterns(["f"])

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["file"]
    end

    test "failed flag clears pattern filters" do
      settings =
        %Settings{}
        |> Settings.only_patterns(["file"])
        |> Settings.only_failed()

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--failed"]
    end

    test "failed flag clears stale flag" do
      settings =
        %Settings{}
        |> Settings.only_stale()
        |> Settings.only_failed()

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--failed"]
    end

    test "stale flag clears pattern filters" do
      settings =
        %Settings{}
        |> Settings.only_patterns(["file"])
        |> Settings.only_stale()

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--stale"]
    end

    test "stale flag clears failed flag" do
      settings =
        %Settings{}
        |> Settings.only_failed()
        |> Settings.only_stale()

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--stale"]
    end

    test "all tests clears pattern filters" do
      settings =
        %Settings{}
        |> Settings.only_patterns(["pattern"])
        |> Settings.all_tests()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "all tests removes stale flag" do
      settings =
        %Settings{}
        |> Settings.only_stale()
        |> Settings.all_tests()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "all tests removes failed flag" do
      settings =
        %Settings{}
        |> Settings.only_failed()
        |> Settings.all_tests()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    defp with_fake_file_list(settings, files) do
      Settings.list_files_with(settings, fn -> files end)
    end
  end

  describe "filtering tests by tags" do
    test "excludes specified tags" do
      tags = ["tag1", "tag2"]
      settings = Settings.with_excludes(%Settings{initial_cli_args: ["--trace"]}, tags)

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "--exclude", "tag1", "--exclude", "tag2"]
    end

    test "clears excluded tags" do
      settings =
        %Settings{}
        |> Settings.with_excludes(["tag1"])
        |> Settings.clear_excludes()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "includes specified tags" do
      tags = ["tag1", "tag2"]
      settings = Settings.with_includes(%Settings{initial_cli_args: ["--trace"]}, tags)

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "--include", "tag1", "--include", "tag2"]
    end

    test "clears included tags" do
      settings =
        %Settings{}
        |> Settings.with_includes(["tag1"])
        |> Settings.clear_includes()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "runs only specified tags" do
      tags = ["tag1", "tag2"]
      settings = Settings.with_only(%Settings{initial_cli_args: ["--trace"]}, tags)

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "--only", "tag1", "--only", "tag2"]
    end

    test "clears only tags" do
      settings =
        %Settings{}
        |> Settings.with_only(["tag1"])
        |> Settings.clear_only()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end
  end

  describe "specifying maximum failures" do
    test "stops after a specified number of failures" do
      max = "3"
      settings = Settings.with_max_failures(%Settings{initial_cli_args: ["--trace"]}, max)

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "--max-failures", max]
    end

    test "clears maximum failures" do
      settings =
        %Settings{}
        |> Settings.with_max_failures("2")
        |> Settings.clear_max_failures()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end
  end

  describe "specifying the seed" do
    test "runs with seed" do
      seed = "5678"
      settings = Settings.with_seed(%Settings{initial_cli_args: ["--trace"]}, seed)

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "--seed", seed]
    end

    test "clears the seed" do
      settings =
        %Settings{}
        |> Settings.with_seed("1234")
        |> Settings.clear_seed()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end
  end

  describe "summary" do
    test "ran all tests" do
      settings = %Settings{}

      assert Settings.summary(settings) == "Ran all tests"
    end

    test "ran all tests with seed" do
      seed = "4242"
      settings = Settings.with_seed(%Settings{}, seed)

      assert Settings.summary(settings) == "Ran all tests with seed: #{seed}"
    end

    test "ran failed tests" do
      settings = Settings.only_failed(%Settings{})

      assert Settings.summary(settings) == "Ran only failed tests"
    end

    test "ran failed tests with seed" do
      seed = "4242"

      settings =
        %Settings{}
        |> Settings.only_failed()
        |> Settings.with_seed(seed)

      assert Settings.summary(settings) == "Ran only failed tests with seed: #{seed}"
    end

    test "ran stale tests" do
      settings = Settings.only_stale(%Settings{})

      assert Settings.summary(settings) == "Ran only stale tests"
    end

    test "ran stale tests with seed" do
      seed = "4242"

      settings =
        %Settings{}
        |> Settings.only_stale()
        |> Settings.with_seed(seed)

      assert Settings.summary(settings) == "Ran only stale tests with seed: #{seed}"
    end

    test "ran specific patterns with seed" do
      seed = "4242"

      settings =
        %Settings{}
        |> Settings.only_patterns(["p1", "p2"])
        |> Settings.with_seed(seed)

      assert Settings.summary(settings) == "Ran all test files matching p1, p2 with seed: #{seed}"
    end

    test "appends max failures" do
      settings = Settings.with_max_failures(%Settings{}, "6")

      assert Settings.summary(settings) =~ "Max failures: 6"
    end

    test "appends tag filters" do
      settings =
        %Settings{}
        |> Settings.with_excludes(["tag1", "tag2"])
        |> Settings.with_includes(["tag3", "tag4"])
        |> Settings.with_only(["tag5", "tag6"])

      summary = Settings.summary(settings)

      assert summary =~ ~s(Excluding tags: ["tag1", "tag2"])
      assert summary =~ ~s(Including tags: ["tag3", "tag4"])
      assert summary =~ ~s(Only tags: ["tag5", "tag6"])
    end
  end
end
