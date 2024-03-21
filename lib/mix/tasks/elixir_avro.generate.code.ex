defmodule Mix.Tasks.ElixirAvro.Generate.Code do
  @moduledoc """
  Mix task to generate elixir modules (enums and structs)
  that map avro schemas.
  """

  use Mix.Task

  alias ElixirAvro.Generator.Content, as: ContentGenerator
  alias ElixirAvro.Schema.Resolver, as: SchemaResolver
  alias Mix.Shell.IO, as: ShellIO

  @impl Mix.Task
  def run([root_path, schemas_path, prefix]) do
    {:ok, _} = Application.ensure_all_started(:elixir_avro)

    File.mkdir_p!(root_path)

    "#{schemas_path}/**/*.avsc"
    |> Path.wildcard()
    |> Enum.map(&File.read!/1)
    |> SchemaResolver.resolve_schema()
    |> ContentGenerator.modules_content_from_schema(prefix)
    |> Enum.each(&write_module(&1, root_path))
  end

  defp write_module({module_name, module_content}, target_path) do
    # Macro.underscore replaces . with /
    filename = Macro.underscore(module_name)

    module_path = Path.join(target_path, "#{filename}.ex")
    File.mkdir_p!(Path.dirname(module_path))

    File.write!(module_path, module_content)

    # Formatting created module
    Mix.Tasks.Format.run([module_path])

    ShellIO.info("Generated #{module_path}")
  end
end
