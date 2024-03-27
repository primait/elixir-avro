defmodule ElixirAvro.Codegen do
  @moduledoc """
  Module responsible for generating elixir modules (enums and structs) from Avro schemas.
  """

  alias ElixirAvro.Schema.Parser
  alias ElixirAvro.Schema.Resolver
  alias ElixirAvro.Template

  alias Mix.Shell.IO

  @type args :: %{
          verbose: boolean,
          target_path: String.t(),
          schemas_path: String.t(),
          prefix: String.t()
        }

  @spec run(args()) :: :ok
  def run(args) do
    {:ok, _} = Application.ensure_all_started(:elixir_avro)

    File.mkdir_p!(args.target_path)

    "#{args.schemas_path}/**/*.avsc"
    |> Path.wildcard()
    |> Enum.map(&File.read!/1)
    |> Resolver.resolve_types()
    |> Parser.from_erl_types()
    |> Template.eval_all!(args.prefix)
    |> Enum.each(&write!(&1, args))
  end

  @spec write!({String.t(), String.t()}, args()) :: :ok
  defp write!({module_name, module_content}, args) do
    # Macro.underscore replaces . with /
    filename = Macro.underscore(module_name)

    module_path = Path.join(args.target_path, "#{filename}.ex")

    module_path
    |> Path.dirname()
    |> File.mkdir_p!()

    File.write!(module_path, module_content)

    log("Generated #{module_path}", args)
  end

  @spec log(String.t(), args() | boolean) :: :ok
  def log(msg, verbose) when is_boolean(verbose) do
    if verbose do
      IO.info(msg)
    end
  end

  def log(msg, args) when is_map(args) do
    verbose = Map.get(args, :verbose, false)
    log(msg, verbose)
  end
end
