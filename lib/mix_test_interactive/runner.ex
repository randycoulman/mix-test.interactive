defmodule MixTestInteractive.Runner do
  @moduledoc """
  Runs tests based on current configuration.

  Also responsible for optionally clearing the terminal and printing the current time.
  """

  alias MixTestInteractive.Config

  @doc """
  Run tests using configured runner.
  """
  @spec run(Config.t(), [String.t()]) :: :ok
  def run(config, args) do
    :ok = maybe_clear_terminal(config)

    IO.puts("")

    [:cyan, :bright, "Running tests..."]
    |> IO.ANSI.format()
    |> IO.puts()

    :ok = maybe_print_timestamp(config)
    config.runner.run(config, args)
  end

  defp maybe_clear_terminal(%{clear?: false}), do: :ok
  defp maybe_clear_terminal(%{clear?: true}), do: :ok = IO.puts(IO.ANSI.clear() <> IO.ANSI.home())

  defp maybe_print_timestamp(%{show_timestamp?: false}), do: :ok

  defp maybe_print_timestamp(%{show_timestamp?: true}) do
    :ok =
      DateTime.utc_now()
      |> DateTime.to_string()
      |> IO.puts()
  end
end
