defmodule Mix.Tasks.ElixirAvro.Generate.Code do
  @moduledoc """
  Mix task to generate elixir modules (enums and structs)
  that map avro schemas.
  """

  use Mix.Task

  alias ElixirAvro.Generator.Module, as: ModuleGenerator
  alias ElixirAvro.Schema.Resolver, as: SchemaResolver
  alias Mix.Shell.IO, as: ShellIO

  @type args :: %{
          verbose: boolean,
          target_path: String.t(),
          schemas_path: String.t(),
          prefix: String.t()
        }

  @aliases [v: :verbose, t: :target_path, s: :schemas_path, p: :prefix]
  @strict [target_path: :string, schemas_path: :string, prefix: :string, verbose: :count]

  @impl Mix.Task
  def run(args) do
    args = parse_args(args)

    {:ok, _} = Application.ensure_all_started(:elixir_avro)

    File.mkdir_p!(args.target_path)

    "#{args.schemas_path}/**/*.avsc"
    |> Path.wildcard()
    |> Enum.map(&File.read!/1)
    |> SchemaResolver.resolve_types()
    |> ModuleGenerator.modules_from_schemas(args.prefix)
    |> Enum.each(&fs_write!(&1, args.target_path, args.verbose))
  end

  @spec parse_args([String.t()]) :: args()
  defp parse_args(args) do
    {parsed, args, invalid} = OptionParser.parse(args, aliases: @aliases, strict: @strict)

    verbose = Keyword.get(parsed, :verbose, false)

    if invalid != [] do
      log("WARN: invalid options '#{inspect(invalid)}'. Ignored!", verbose)
    end

    if args != [] do
      log("WARN: extra args not needed '#{args}'. Ignored!", verbose)
    end

    target_path = fetch!(parsed, :target_path)
    schemas_path = fetch!(parsed, :schemas_path)
    prefix = fetch!(parsed, :prefix)

    %{verbose: verbose, target_path: target_path, schemas_path: schemas_path, prefix: prefix}
  end

  @spec fs_write!({String.t(), String.t()}, String.t(), boolean) :: :ok
  defp fs_write!({module_name, module_content}, target_path, verbose) do
    # Macro.underscore replaces . with /
    filename = Macro.underscore(module_name)

    module_path = Path.join(target_path, "#{filename}.ex")
    File.mkdir_p!(Path.dirname(module_path))

    File.write!(module_path, module_content)

    # Formatting created module
    Mix.Tasks.Format.run([module_path])

    log("Generated #{module_path}", verbose)
  end

  defp fetch!(args, key) do
    case Keyword.fetch(args, key) do
      {:ok, value} -> value
      :error -> raise "Missing #{key} option"
    end
  end

  @spec log(String.t(), boolean) :: :ok
  defp log(msg, verbose) do
    if verbose do
      ShellIO.info(msg)
    end
  end
end
