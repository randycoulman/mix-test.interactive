defmodule MixTestInteractive.InteractiveMode do
  @moduledoc """
  Main loop for interactive mode.

  Repeatedly reads commands from the user, processes them, optionally runs
  the tests, and then prints out summary/usage information.
  """

  alias MixTestInteractive.{CommandProcessor, Config, ConfigStore, Runner}

  @doc """
  Start the interactive mode loop.
  """
  @spec start(Config.t()) :: no_return()
  def start(config) do
    ConfigStore.store(config)
    run(config)
    loop(config)
  end

  @doc false
  def run(config) do
    :ok = run_tests(config)
    show_summary(config)
    show_usage_prompt(config)
  end

  defp loop(config) do
    command = IO.gets("")

    case CommandProcessor.call(command, config) do
      {:ok, new_config} ->
        ConfigStore.store(new_config)
        run(new_config)
        loop(new_config)

      {:no_run, new_config} ->
        ConfigStore.store(new_config)
        show_usage_prompt(new_config)
        loop(new_config)

      :help ->
        show_help(config)
        loop(config)

      :unknown ->
        loop(config)

      :quit ->
        :ok
    end
  end

  defp run_tests(config) do
    with :ok <- Runner.run(config) do
      :ok
    else
      {:error, :no_matching_files} ->
        [:red, "No matching tests found"]
        |> IO.ANSI.format()
        |> IO.puts()

        :ok

      error ->
        error
    end
  end

  defp show_summary(config) do
    IO.puts("")

    config
    |> Config.summary()
    |> IO.puts()
  end

  defp show_usage_prompt(config) do
    IO.puts("")

    if config.watching? do
      IO.puts("Watching for file changes...")
    else
      IO.puts("Ignoring file changes")
    end

    IO.puts("")

    [:bright, "Usage: ?", :normal, " to show more"]
    |> IO.ANSI.format()
    |> IO.puts()
  end

  defp show_help(config) do
    IO.puts("")

    config
    |> CommandProcessor.usage()
    |> IO.puts()
  end
end
