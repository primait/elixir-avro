defmodule ElixirAvro.Generator.Content do
  @moduledoc false

  alias ElixirAvro.Generator.Names

  @spec modules_content_from_schema(
          schema_content :: String.t(),
          read_schema_fun :: fun(),
          module_prefix :: String.t()
        ) :: map
  def modules_content_from_schema(root_schema_content, read_schema_fun, module_prefix) do
    root_schema_content
    |> ElixirAvro.SchemaParser.parse(read_schema_fun)
    |> Enum.map(fn {_fullname, erlavro_type} -> module_content(erlavro_type, module_prefix) end)
    |> Enum.into(%{})
  end

  @spec module_content(erlavro_schema_parsed :: tuple, module_prefix :: String.t()) ::
          {String.t(), String.t()}
  defp module_content(
         erlavro_schema_parsed,
         module_prefix
       ) do
    moduledoc = module_doc(erlavro_schema_parsed)
    module_name = module_name(erlavro_schema_parsed, module_prefix)

    bindings =
      [
        moduledoc: moduledoc,
        module_name: module_name,
        module_prefix: module_prefix
      ] ++ get_spefic_bindings(erlavro_schema_parsed)

    module_content =
      eval_template!(template_path(erlavro_schema_parsed), bindings,
        locals_without_parens: [{:field, :*}]
      )

    {module_name, module_content}
  end

  defp get_spefic_bindings(
         {:avro_record_type, _name, _namespace, _doc, _, _fields, _fullname, _} =
           erlavro_schema_parsed
       ) do
    [fields_meta: fields_meta(erlavro_schema_parsed)]
  end

  defp get_spefic_bindings(
         {:avro_enum_type, _name, _namespace, _aliases, _doc, symbols, _fullname, _custom}
       ) do
    [values: symbols]
  end

  defp template_path({:avro_record_type, _name, _namespace, _doc, _, _fields, _fullname, _}) do
    Path.join(__DIR__, "templates/record.ex.eex")
  end

  defp template_path(
         {:avro_enum_type, _name, _namespace, _aliases, _doc, _symbols, _fullname, _custom}
       ) do
    Path.join(__DIR__, "templates/enum.ex.eex")
  end

  defp module_name(
         {:avro_record_type, _name, _namespace, _doc, _, _fields, fullname, _},
         module_prefix
       ) do
    module_prefix <> "." <> Names.camelize(fullname)
  end

  defp module_name(
         {:avro_enum_type, _name, _namespace, _aliases, _doc, _symbols, fullname, _custom},
         module_prefix
       ) do
    module_prefix <> "." <> Names.camelize(fullname)
  end

  defp module_doc(
         {:avro_record_type, _name, _namespace, doc, _aliases, _fields, _fullname, _custom}
       ) do
    doc
  end

  defp module_doc(
         {:avro_enum_type, _name, _namespace, _aliases, doc, _symbols, _fullname, _custom}
       ) do
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

  defp fields_meta({:avro_record_type, _name, _namespace, _doc, _, fields, _fullname, _}) do
    Enum.map(fields, &field_meta/1)
  end

  defp field_meta({:avro_record_field, name, doc, type, :undefined, :ascending, _aliases}) do
    %{
      doc: doc,
      name: name,
      erlavro_type: type
    }
  end
end
