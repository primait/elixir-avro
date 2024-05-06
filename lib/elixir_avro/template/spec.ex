defmodule ElixirAvro.Template.Spec do
  @moduledoc """
  Module responsible for generating typespecs from Avro type.
  """

  alias ElixirAvro.AvroType
  alias ElixirAvro.AvroType.Array
  alias ElixirAvro.AvroType.Fixed
  alias ElixirAvro.AvroType.Primitive
  alias ElixirAvro.AvroType.Union
  alias ElixirAvro.Template.Names

  @doc ~S"""
  Decides whether to enforce typedstruct types or not based on which avro type is being used.
  """
  @spec enforce?(AvroType.t()) :: boolean
  def enforce?(%Union{}), do: false
  def enforce?(_), do: true

  @doc ~S"""
  Returns the string to be used as elixir type for any avro type.

  # Examples

  ## Primitive types

  iex> to_typedstruct_spec!(%Primitive{name: "boolean"}, "my_prefix")
  "boolean()"

  iex> to_typedstruct_spec!(%Primitive{name: "bytes"}, "my_prefix")
  "binary()"

  iex> to_typedstruct_spec!(%Primitive{name: "double"}, "my_prefix")
  "float()"

  iex> to_typedstruct_spec!(%Primitive{name: "float"}, "my_prefix")
  "float()"

  iex> to_typedstruct_spec!(%Primitive{name: "int"}, "my_prefix")
  "integer()"

  iex> to_typedstruct_spec!(%Primitive{name: "long"}, "my_prefix")
  "integer()"

  iex> to_typedstruct_spec!(%Primitive{name: "null"}, "my_prefix")
  "nil"

  iex> to_typedstruct_spec!(%Primitive{name: "string"}, "my_prefix")
  "String.t()"

  An unknown type will raise an ArgumentError:

  iex> to_typedstruct_spec!(%Primitive{name: "non-existent-type"}, "my_prefix")
  ** (ArgumentError) unsupported type: "non-existent-type"

  ## Logical types

  iex> to_typedstruct_spec!(%Primitive{name: "bytes", custom_props: [
  ...>    %CustomProp{name: "logicalType", value: "decimal"}, %CustomProp{name: "precision", value: 4}, %CustomProp{name: "scale", value: 2}
  ...>  ]},
  ...>  "my_prefix")
  "Decimal.t()"

  iex> to_typedstruct_spec!(%Primitive{name: "string", custom_props: [%CustomProp{name: "logicalType", value: "uuid"}]}, "my_prefix")
  "String.t()"

  iex> to_typedstruct_spec!(%Primitive{name: "int", custom_props: [%CustomProp{name: "logicalType", value: "date"}]}, "my_prefix")
  "Date.t()"

  iex> to_typedstruct_spec!(%Primitive{name: "int", custom_props: [%CustomProp{name: "logicalType", value: "time-millis"}]}, "my_prefix")
  "Time.t()"

  iex> to_typedstruct_spec!(%Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "time-micros"}]}, "my_prefix")
  "Time.t()"

  iex> to_typedstruct_spec!(%Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "timestamp-millis"}]}, "my_prefix")
  "DateTime.t()"

  iex> to_typedstruct_spec!(%Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "timestamp-micros"}]}, "my_prefix")
  "DateTime.t()"

  iex> to_typedstruct_spec!(%Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "local-timestamp-millis"}]}, "my_prefix")
  "NaiveDateTime.t()"

  iex> to_typedstruct_spec!(%Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "local-timestamp-micros"}]}, "my_prefix")
  "NaiveDateTime.t()"

  An unknown logical type or a non-existent {primitive, logical} type combination will raise an ArgumentError:

  iex> to_typedstruct_spec!(%Primitive{name: "int", custom_props: [%CustomProp{name: "logicalType", value: "unsupported-logical-type"}]}, "my_prefix")
  ** (ArgumentError) unsupported logical type: int => unsupported-logical-type

  iex> to_typedstruct_spec!(%Primitive{name: "string", custom_props: [%CustomProp{name: "logicalType", value: "timestamp-millis"}]}, "my_prefix")
  ** (ArgumentError) unsupported logical type: string => timestamp-millis

  ## Fixed types

  iex> to_typedstruct_spec!(%Fixed{name: "md5", namespace: "test", aliases: [], size: 16, fullname: "test.md5"}, "my_prefix")
  "<<_::128>>"

  ## Array types

  iex> to_typedstruct_spec!(%Array{type: %Primitive{name: "string"}}, "my_prefix")
  "[String.t()]"

  iex> to_typedstruct_spec!(%Array{type: %Primitive{name: "int", custom_props: [%CustomProp{name: "logicalType", value: "date"}]}}, "my_prefix")
  "[Date.t()]"

  Primitive types error logic still applies:

  iex> to_typedstruct_spec!(%Array{type: %Primitive{name: "string", custom_props: [%CustomProp{name: "logicalType", value: "date"}]}}, "my_prefix")
  ** (ArgumentError) unsupported logical type: string => date

  ## Map types

  iex> to_typedstruct_spec!(%Map{type: %Primitive{name: "int"}}, "my_prefix")
  "%{String.t() => integer()}"

  iex> to_typedstruct_spec!(%Map{type: %Primitive{name: "int", custom_props: [%CustomProp{name: "logicalType", value: "time-millis"}]}}, "my_prefix")
  "%{String.t() => Time.t()}"

  Primitive types error logic still applies:

  iex> to_typedstruct_spec!(%Map{type: %Primitive{name: "string", custom_props: [%CustomProp{name: "logicalType", value: "date"}]}}, "my_prefix")
  ** (ArgumentError) unsupported logical type: string => date

  ## Union types

  iex> to_typedstruct_spec!(
  ...>  %Union{values: %{
  ...>    0 => %Primitive{name: "null"},
  ...>    1 => %Primitive{name: "string"}
  ...>  }}, "my_prefix")
  "nil | String.t()"

  iex> to_typedstruct_spec!(
  ...>  %Union{values: %{
  ...>    0 => %Primitive{name: "null"},
  ...>    1 => %Primitive{name: "int", custom_props: [%CustomProp{name: "logicalType", value: "time-millis"}]}
  ...>  }}, "my_prefix")
  "nil | Time.t()"

  ## References

  iex> to_typedstruct_spec!("test.Type", "my_prefix")
  "MyPrefix.Test.Type.t()"
  """
  @spec to_typedstruct_spec!(AvroType.t(), String.t()) :: String.t() | no_return()
  def to_typedstruct_spec!(%Primitive{} = type, _), do: Primitive.to_typedstruct_spec!(type)

  def to_typedstruct_spec!(%Fixed{size: size}, _) do
    "<<_::#{size * 8}>>"
  end

  def to_typedstruct_spec!(%Array{type: type}, module_prefix) do
    "[#{to_typedstruct_spec!(type, module_prefix)}]"
  end

  def to_typedstruct_spec!(%AvroType.Map{type: type}, module_prefix) do
    "%{String.t() => #{to_typedstruct_spec!(type, module_prefix)}}"
  end

  def to_typedstruct_spec!(%Union{values: union_values}, module_prefix) do
    Enum.map_join(union_values, " | ", fn {_id, type} ->
      to_typedstruct_spec!(type, module_prefix)
    end)
  end

  def to_typedstruct_spec!(reference, module_prefix) when is_binary(reference) do
    Names.module_name!(reference, module_prefix) <> ".t()"
  end

  def to_typedstruct_spec!(type, _) do
    raise ArgumentError, message: "unsupported avro type: #{inspect(type)}"
  end
end
