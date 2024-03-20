defmodule ElixirAvro.Generator.Content do
  @moduledoc false

  alias ElixirAvro.Generator.Names
  alias ElixirAvro.Schema

  @spec modules_content_from_schema(
          schema_content :: String.t(),
          read_schema_fun :: fun(),
          module_prefix :: String.t()
        ) :: map
  def modules_content_from_schema(root_schema_content, read_schema_fun, module_prefix) do
    root_schema_content
    |> ElixirAvro.Schema.Parser.parse(read_schema_fun)
    |> Enum.map(fn {_fullname, schema_type} -> module_content(schema_type, module_prefix) end)
    |> Enum.into(%{})
  end

  @spec module_content(
          schema_type :: Schema.Record.t() | Schema.Enum.t(),
          module_prefix :: String.t()
        ) :: {String.t(), String.t()}
  defp module_content(schema_type, module_prefix) do
    module_name = module_name(schema_type, module_prefix)
    specific_bindings = apply(schema_type.__struct__, :get_specific_bindings, [schema_type])

    bindings =
      [
        moduledoc: schema_type.doc,
        module_name: module_name,
        module_prefix: module_prefix
      ] ++ specific_bindings

    module_content =
      eval_template!(schema_type.template_path, bindings, locals_without_parens: [{:field, :*}])

    {module_name, module_content}
  end

  # Evaluate the template file at `path` using the given `bindings`, then formats
  # it using the Elixir's code formatter and adds a trailing new line.
  # The `opts` are passed to `Code.format_string!/2`.
  @spec eval_template!(String.t(), Keyword.t(), Keyword.t()) :: String.t()
  defp eval_template!(path, bindings, opts) do
    opts = Keyword.merge([line_length: 120], opts)

    path
    |> EEx.eval_file(bindings)
    |> Code.format_string!(opts)
    |> to_string()
    |> Kernel.<>("\n")
  end

  @spec module_name(Schema.Record.t() | Schema.Enum.t(), String.t()) :: String.t()
  defp module_name(%Schema.Record{fullname: fullname}, module_prefix) do
    module_prefix <> "." <> Names.camelize(fullname)
  end

  defp module_name(%Schema.Enum{fullname: fullname}, module_prefix) do
    module_prefix <> "." <> Names.camelize(fullname)
  end
end
