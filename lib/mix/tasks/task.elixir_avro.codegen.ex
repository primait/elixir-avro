defmodule Mix.Tasks.ElixirAvroCodegen do
  @moduledoc """
  Mix task to generate elixir modules (enums and structs) that map avro schemas.

  # Usage

  This mix task could be run using:

  ```shell
  mix elixir_avro_codegen -t <target_path> -s <schemas_path> -p <prefix> [-v]
  ```
  """

  use Mix.Task

  @aliases [v: :verbose, t: :target_path, s: :schemas_path, p: :prefix]
  @strict [target_path: :string, schemas_path: :string, prefix: :string, verbose: :count]

  @impl Mix.Task
  def run(args) do
    args
    |> parse_args()
    |> ElixirAvro.Codegen.run()
  end

  @spec parse_args([String.t()]) :: ElixirAvro.Codegen.args()
  defp parse_args(args) do
    {parsed, args, invalid} = OptionParser.parse(args, aliases: @aliases, strict: @strict)

    verbose = Keyword.get(parsed, :verbose, false)

    if invalid != [] do
      ElixirAvro.Codegen.log("WARN: invalid options '#{inspect(invalid)}'. Ignored!", verbose)
    end

    if args != [] do
      ElixirAvro.Codegen.log("WARN: extra args not needed '#{args}'. Ignored!", verbose)
    end

    target_path = fetch!(parsed, :target_path)
    schemas_path = fetch!(parsed, :schemas_path)
    prefix = fetch!(parsed, :prefix)

    %{verbose: verbose, target_path: target_path, schemas_path: schemas_path, prefix: prefix}
  end

  @spec fetch!([{atom(), String.t()}], atom()) :: String.t()
  defp fetch!(args, key) do
    case Keyword.fetch(args, key) do
      {:ok, value} -> value
      :error -> raise "Missing #{key} option"
    end
  end
end
