defmodule ElixirAvro.Template do
  @moduledoc """
  Module responsible for processing templates.
  """

  alias ElixirAvro.AvroType
  alias ElixirAvro.Template.Names

  @type t :: %__MODULE__{
          doc: String.t(),
          name: String.t(),
          prefix: String.t(),
          fields: [AvroType.RecordField.t()],
          symbols: [String.t()]
        }

  defstruct [:doc, :name, :prefix, fields: [], symbols: []]

  @opts [locals_without_parens: [{:field, :*}], line_length: 120]
  @formatter_file ".formatter.exs"

  @doc ~S"""
  Evaluates the all types applying the given template.

  # Examples

  NOTE: put here all the examples.
  """
  @spec eval_all!([AvroType.t()], String.t()) :: %{String.t() => String.t()}
  def eval_all!(types, prefix), do: types |> Enum.map(&eval!(&1, prefix)) |> Enum.into(%{})

  @spec eval!(AvroType.t(), String.t()) :: {String.t(), String.t()}
  def eval!(avro_type, prefix) do
    self = from_avro_type(avro_type, prefix)
    path = template_path_from_avro_type(avro_type)
    opts = formatter_opts()

    content =
      path
      |> EEx.eval_file(template: self)
      |> Code.format_string!(opts)
      |> to_string()
      |> Kernel.<>("\n")

    {self.name, content}
  end

  @spec from_avro_type(AvroType.t(), String.t()) :: t()
  defp from_avro_type(%AvroType.Record{} = type, prefix) do
    %__MODULE__{
      doc: type.doc,
      name: Names.module_name!(type.fullname, prefix),
      prefix: prefix,
      fields: type.fields
    }
  end

  @spec from_avro_type(AvroType.t(), String.t()) :: t()
  defp from_avro_type(%AvroType.Enum{doc: doc, fullname: fullname, symbols: symbols}, prefix) do
    %__MODULE__{
      doc: doc,
      name: Names.module_name!(fullname, prefix),
      prefix: prefix,
      symbols: symbols
    }
  end

  defp from_avro_type(t, _), do: raise("cannot eval template for #{t.__struct__} type")

  @spec template_path_from_avro_type(AvroType.t()) :: String.t() | no_return
  defp template_path_from_avro_type(%AvroType.Record{}) do
    Path.join(__DIR__, "template/file/record.ex.eex")
  end

  defp template_path_from_avro_type(%AvroType.Enum{}) do
    Path.join(__DIR__, "template/file/enum.ex.eex")
  end

  defp template_path_from_avro_type(t), do: raise("template not found for #{t.__struct__} type")

  @spec formatter_opts() :: Keyword.t()
  defp formatter_opts do
    if File.exists?(@formatter_file) do
      case @formatter_file |> File.read!() |> Code.eval_string() do
        {opts, []} -> opts
        _ -> @opts
      end
    else
      @opts
    end
  end
end
