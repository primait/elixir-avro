defmodule ElixirAvro.Template.Renderer do
  @moduledoc """
  Module responsible for processing field templates.
  """

  alias ElixirAvro.AvroType.RecordField
  alias ElixirAvro.Template
  alias ElixirAvro.Template.Spec

  @excribe_opts %{hanging: 6, width: 80, indent: 0, align: :left}

  @doc """
  Renders the @moduledoc documentation for the given fields.
  """
  @spec module_doc(Template.t()) :: String.t()
  def module_doc(%Template{fields: fields}) do
    Enum.map_join(fields, "\n", &doc/1)
  end

  @spec doc(RecordField.t()) :: String.t()
  defp doc(field) do
    "- __#{field.name}__: #{field.doc}"
    |> String.trim()
    |> Excribe.format(@excribe_opts)
  end

  @doc """
  Renders the @expected_keys module attribute for the given fields.
  """
  @spec expected_keys(Template.t()) :: String.t()
  def expected_keys(%Template{fields: fields}) do
    "[#{Enum.map_join(fields, ", ", &~s/"#{&1.name}"/)}]"
  end

  @doc """
  Renders the @values for enum types.
  """
  @spec values(Template.t()) :: String.t()
  def values(%Template{symbols: symbols}) do
    Enum.map_join(symbols, ", ", &~s/"#{&1}"/)
  end

  @doc """
  Renders the typestruct fields with their specs.
  """
  @spec typedstruct_fields(Template.t()) :: String.t()
  def typedstruct_fields(%Template{prefix: prefix, fields: fields}) do
    Enum.map_join(fields, "\n", &typedstruct_field(&1, prefix))
  end

  @spec typedstruct_field(RecordField.t(), String.t()) :: String.t()
  defp typedstruct_field(%RecordField{name: name, type: type}, prefix) do
    "field :#{name}, #{Spec.to_typedstruct_spec!(type, prefix)}, enforce: #{Spec.enforce?(type)}"
  end

  @spec fields_for_to_avro(Template.t()) :: String.t()
  def fields_for_to_avro(%Template{fields: fields}) do
    Enum.map_join(fields, ", ", fn %RecordField{name: name} = field ->
      "\"#{name}\" => Encoder.encode_value!(struct.#{name}, #{inspect(field.type)}, @module_prefix)"
    end)
  end

  @spec args_for_from_avro(Template.t()) :: String.t()
  def args_for_from_avro(%Template{fields: fields}) do
    Enum.map_join(fields, ", ", &~s/"#{&1.name}" => #{&1.name}/)
  end

  @spec fields_for_from_avro(Template.t()) :: String.t()
  def fields_for_from_avro(%Template{fields: fields}) do
    Enum.map_join(fields, ", ", fn %RecordField{name: name} = field ->
      "#{name}: Decoder.decode_value!(#{name}, #{inspect(field.type)}, @module_prefix)"
    end)
  end
end
