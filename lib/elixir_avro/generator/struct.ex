defmodule ElixirAvro.Generator.Struct do
  @moduledoc false

  alias ElixirAvro.Generator.Names

  @type field_meta :: %{
          doc: String.t(),
          name: String.t(),
          erlavro_type: String.t()
        }

  @spec from_schema(:avro_schema_store.store(), String.t()) :: map
  def from_schema(lookup_table, module_prefix) do
    lookup_table
    |> Enum.map(fn {_fullname, schema_type} -> module_content(schema_type, module_prefix) end)
    |> Enum.into(%{})
  end

  @spec module_content(
          schema :: :avro.avro_type(),
          module_prefix :: String.t()
        ) :: {String.t(), String.t()}
  defp module_content(schema, module_prefix) do
    moduledoc = module_doc(schema)
    module_name = module_name(schema, module_prefix)
    specific_bindings = get_specific_bindings(schema)
    template_path = template_path(schema)

    bindings =
      [
        moduledoc: moduledoc,
        module_name: module_name,
        module_prefix: module_prefix
      ] ++ specific_bindings

    module_content =
      eval_template!(template_path, bindings, locals_without_parens: [{:field, :*}])

    {module_name, module_content}
  end

  @spec get_specific_bindings(tuple) :: [fields_meta: [field_meta]]
  defp get_specific_bindings({:avro_record_type, _, _, _, _, _, _, _} = erlavro_schema_parsed) do
    [fields_meta: fields_meta(erlavro_schema_parsed)]
  end

  defp get_specific_bindings({:avro_enum_type, _, _, _, _, symbols, _, _}) do
    [values: symbols]
  end

  @spec template_path(tuple) :: String.t()
  defp template_path({:avro_record_type, _, _, _, _, _, _, _}) do
    Path.join(__DIR__, "templates/record.ex.eex")
  end

  defp template_path({:avro_enum_type, _, _, _, _, _, _, _}) do
    Path.join(__DIR__, "templates/enum.ex.eex")
  end

  @spec module_name(tuple, String.t()) :: String.t()
  defp module_name({:avro_record_type, _, _, _, _, _, fullname, _}, module_prefix) do
    module_prefix <> "." <> Names.camelize(fullname)
  end

  defp module_name({:avro_enum_type, _, _, _, _, _, fullname, _}, module_prefix) do
    module_prefix <> "." <> Names.camelize(fullname)
  end

  @spec module_doc(tuple) :: String.t()
  defp module_doc({:avro_record_type, _, _, doc, _, _, _, _}) do
    doc
  end

  defp module_doc({:avro_enum_type, _, _, _, doc, _, _, _}) do
    doc
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

  @spec get_specific_bindings(tuple) :: [fields_meta: [field_meta]] | [values: [String.t()]]
  defp get_specific_bindings(
         {:avro_record_type, _name, _namespace, _doc, _, _fields, _fullname, _} =
           erlavro_schema_parsed
       ) do
    [fields_meta: fields_meta(erlavro_schema_parsed)]
  end

  defp get_specific_bindings({:avro_enum_type, _, _, _, _, symbols, _, _}) do
    [values: symbols]
  end

  @spec template_path(tuple) :: String.t()
  defp template_path({:avro_record_type, _, _, _, _, _, _, _}) do
    Path.join(__DIR__, "templates/record.ex.eex")
  end

  defp template_path({:avro_enum_type, _, _, _, _, _, _, _}) do
    Path.join(__DIR__, "templates/enum.ex.eex")
  end

  @spec module_name(tuple, String.t()) :: String.t()
  defp module_name({:avro_record_type, _, _, _, _, _, fullname, _}, module_prefix) do
    module_prefix <> "." <> Names.camelize(fullname)
  end

  defp module_name({:avro_enum_type, _, _, _, _, _, fullname, _}, module_prefix) do
    module_prefix <> "." <> Names.camelize(fullname)
  end

  @spec module_doc(tuple) :: String.t()
  defp module_doc({:avro_record_type, _, _, doc, _, _, _, _}) do
    doc
  end

  defp module_doc({:avro_enum_type, _, _, _, doc, _, _, _}) do
    doc
  end

  @spec fields_meta(tuple) :: [field_meta]
  defp fields_meta({:avro_record_type, _name, _namespace, _doc, _, fields, _fullname, _}) do
    Enum.map(fields, &field_meta/1)
  end

  @spec field_meta(tuple) :: field_meta
  defp field_meta({:avro_record_field, name, doc, type, :undefined, :ascending, _aliases}) do
    %{
      doc: doc,
      name: name,
      erlavro_type: type
    }
  end
end
