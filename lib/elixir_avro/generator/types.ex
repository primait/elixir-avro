defmodule ElixirAvro.Generator.Types do
  @moduledoc """
  This module contains utility functions for conversion and typesecs of avro
  types from and into elixir types.
  """

  alias ElixirAvro.Generator.Names

  require Decimal

  # see: https://avro.apache.org/docs/1.11.0/spec.html#schema_primitive
  @primitive_type_spec_strings %{
    "null" => "nil",
    "boolean" => "boolean()",
    "int" => "integer()",
    "long" => "integer()",
    "float" => "float()",
    "double" => "float()",
    "bytes" => "binary()",
    "string" => "String.t()"
  }

  # see: https://avro.apache.org/docs/1.11.0/spec.html#Logical+Types
  @logical_types_spec_strings %{
    {"bytes", "decimal"} => "Decimal.t()",
    {"string", "uuid"} => "String.t()",
    {"int", "date"} => "Date.t()",
    {"int", "time-millis"} => "Time.t()",
    {"long", "time-micros"} => "Time.t()",
    {"long", "timestamp-millis"} => "DateTime.t()",
    {"long", "timestamp-micros"} => "DateTime.t()",
    {"long", "local-timestamp-millis"} => "NaiveDateTime.t()",
    {"long", "local-timestamp-micros"} => "NaiveDateTime.t()"
    # avro specific custom implemented duration (incompatible with Timex.Duration) - leaving it out for the moment
    # {"fixed", "duration"} => "ElixirBrod.Avro.Duration.t()"
  }

  def to_typedstruct_spec!(type, module_prefix) do
    to_typespec!(type, module_prefix) <> ", enforce: #{enforce?(type)}"
  end

  def enforce?({:avro_union_type, _, _}) do
    false
  end

  def enforce?(_type) do
    true
  end

  @doc ~S"""
  Returns the string to be used as elixir type for any avro type.

  # Examples

  ## Primitive types

  iex> to_typespec!({:avro_primitive_type, "boolean", []}, "my_prefix")
  "boolean()"

  iex> to_typespec!({:avro_primitive_type, "bytes", []}, "my_prefix")
  "binary()"

  iex> to_typespec!({:avro_primitive_type, "double", []}, "my_prefix")
  "float()"

  iex> to_typespec!({:avro_primitive_type, "float", []}, "my_prefix")
  "float()"

  iex> to_typespec!({:avro_primitive_type, "int", []}, "my_prefix")
  "integer()"

  iex> to_typespec!({:avro_primitive_type, "long", []}, "my_prefix")
  "integer()"

  iex> to_typespec!({:avro_primitive_type, "null", []}, "my_prefix")
  "nil"

  iex> to_typespec!({:avro_primitive_type, "string", []}, "my_prefix")
  "String.t()"

  An unknown type will raise an ArgumentError:

  iex> to_typespec!({:avro_primitive_type, "non-existent-type", []}, "my_prefix")
  ** (ArgumentError) unsupported type: "non-existent-type"

  ## Logical types

  iex> to_typespec!({:avro_primitive_type, "bytes", [{"logicalType", "decimal"}, {"precision", 4}, {"scale", 2}]}, "my_prefix")
  "Decimal.t()"

  iex> to_typespec!({:avro_primitive_type, "string", [{"logicalType", "uuid"}]}, "my_prefix")
  "String.t()"

  iex> to_typespec!({:avro_primitive_type, "int", [{"logicalType", "date"}]}, "my_prefix")
  "Date.t()"

  iex> to_typespec!({:avro_primitive_type, "int", [{"logicalType", "time-millis"}]}, "my_prefix")
  "Time.t()"

  iex> to_typespec!({:avro_primitive_type, "long", [{"logicalType", "time-micros"}]}, "my_prefix")
  "Time.t()"

  iex> to_typespec!({:avro_primitive_type, "long", [{"logicalType", "timestamp-millis"}]}, "my_prefix")
  "DateTime.t()"

  iex> to_typespec!({:avro_primitive_type, "long", [{"logicalType", "timestamp-micros"}]}, "my_prefix")
  "DateTime.t()"

  iex> to_typespec!({:avro_primitive_type, "long", [{"logicalType", "local-timestamp-millis"}]}, "my_prefix")
  "NaiveDateTime.t()"

  iex> to_typespec!({:avro_primitive_type, "long", [{"logicalType", "local-timestamp-micros"}]}, "my_prefix")
  "NaiveDateTime.t()"

  An unknown logical type or a non-existent {primitive, logical} type combination will raise an ArgumentError:

  iex> to_typespec!({:avro_primitive_type, "int", [{"logicalType", "unsupported-logical-type"}]}, "my_prefix")
  ** (ArgumentError) unsupported type: {"int", "unsupported-logical-type"}

  iex> to_typespec!({:avro_primitive_type, "string", [{"logicalType", "timestamp-millis"}]}, "my_prefix")
  ** (ArgumentError) unsupported type: {"string", "timestamp-millis"}

  ## Fixed types

  iex> to_typespec!({:avro_fixed_type, "md5", "test", [], 16, "test.md5", []}, "my_prefix")
  "<<_::128>>"

  ## Array types

  iex> to_typespec!({:avro_array_type, {:avro_primitive_type, "string", []}, []}, "my_prefix")
  "[String.t()]"

  iex> to_typespec!({:avro_array_type, {:avro_primitive_type, "int", [{"logicalType", "date"}]}, []}, "my_prefix")
  "[Date.t()]"

  Primitive types error logic still applies:

  iex> to_typespec!({:avro_array_type, {:avro_primitive_type, "string", [{"logicalType", "date"}]}, []}, "my_prefix")
  ** (ArgumentError) unsupported type: {"string", "date"}

  ## Map types

  iex> to_typespec!({:avro_map_type, {:avro_primitive_type, "int", []}, []}, "my_prefix")
  "%{String.t() => integer()}"

  iex> to_typespec!({:avro_map_type, {:avro_primitive_type, "int", [{"logicalType", "time-millis"}]}, []}, "my_prefix")
  "%{String.t() => Time.t()}"

  Primitive types error logic still applies:

  iex> to_typespec!({:avro_map_type, {:avro_primitive_type, "string", [{"logicalType", "date"}]}, []}, "my_prefix")
  ** (ArgumentError) unsupported type: {"string", "date"}

  ## Union types

  iex> to_typespec!({:avro_union_type,
  ...>  {2,
  ...>   {1, {:avro_primitive_type, "string", []},
  ...>    {0, {:avro_primitive_type, "null", []}, nil, nil}, nil}},
  ...>  {2, {"string", {1, true}, {"null", {0, true}, nil, nil}, nil}}}, "my_prefix")
  "nil | String.t()"

  ## References

  iex> to_typespec!("test.Type", "my_prefix")
  "MyPrefix.Test.Type.t()"

  ## Unsupported types

  iex> to_typespec!({:avro_unsupported_type, {:avro_primitive_type, "int", []}, []}, "my_prefix")
  ** (ArgumentError) unsupported avro type: {:avro_unsupported_type, {:avro_primitive_type, "int", []}, []}
  """
  @spec to_typespec!(:avro.type_or_name(), module_prefix :: String.t()) ::
          String.t() | no_return()
  def to_typespec!({:avro_primitive_type, name, custom}, _module_prefix) do
    case List.keyfind(custom, "logicalType", 0) do
      nil ->
        get_spec_string(@primitive_type_spec_strings, name)

      {"logicalType", logical_type} ->
        get_spec_string(@logical_types_spec_strings, {name, logical_type})
    end
  end

  def to_typespec!(
        {:avro_fixed_type, _name, _namespace, _aliases, size, _fullname, _custom},
        _module_prefix
      ) do
    "<<_::#{size * 8}>>"
  end

  def to_typespec!({:avro_array_type, type, _custom}, module_prefix) do
    "[#{to_typespec!(type, module_prefix)}]"
  end

  def to_typespec!({:avro_map_type, type, _custom}, module_prefix) do
    "%{String.t() => #{to_typespec!(type, module_prefix)}}"
  end

  def to_typespec!({:avro_union_type, _id2type, _name2id} = union, module_prefix) do
    union
    |> :avro_union.get_types()
    |> Enum.map_join(" | ", &to_typespec!(&1, module_prefix))
  end

  def to_typespec!(reference, module_prefix) do
    Names.module_name!(reference, module_prefix) <> ".t()"
  end

  def to_typespec!(type, _base_path) do
    raise ArgumentError, message: "unsupported avro type: #{inspect(type)}"
  end

  @spec get_spec_string(map, String.t() | {String.t(), String.t()}) :: String.t() | no_return()
  defp get_spec_string(types_map, type) do
    case Map.get(types_map, type) do
      nil -> raise ArgumentError, message: "unsupported type: #{inspect(type)}"
      type -> type
    end
  end

  @spec encode_value!(any(), :avro.type_or_name(), module_prefix :: String.t()) ::
          any() | no_return()
  def encode_value!(value, type, module_prefix) do
    case encode_value(value, type, module_prefix) do
      {:ok, value} -> value
      {:error, error} -> raise "Error during encoding of value: #{inspect(error)}"
    end
  end

  @doc ~S"""
  Encodes any value into an avro compatible format.

  # Examples

  ## Primitive types

  iex> encode_value(true, {:avro_primitive_type, "boolean", []}, "")
  {:ok, true}

  iex> encode_value(25, {:avro_primitive_type, "int", []}, "")
  {:ok, 25}

  iex> encode_value(2_147_483_648, {:avro_primitive_type, "int", []}, "")
  {:error, "value out of range"}

  iex> encode_value(~D[2024-01-01], {:avro_primitive_type, "int", [{"logicalType", "date"}]}, "")
  {:ok, 19723}

  iex> encode_value(~T[01:01:01.123], {:avro_primitive_type, "int", [{"logicalType", "time-millis"}]}, "")
  {:ok, 3661123}

  iex> encode_value(~T[04:05:06.001002], {:avro_primitive_type, "int", [{"logicalType", "date"}]}, "")
  {:error, "not a date value"}

  iex> encode_value(~T[07:08:19.000123], {:avro_primitive_type, "long", [{"logicalType", "time-micros"}]}, "")
  {:ok, 25699000123}

  iex> encode_value(~U[2024-01-01 01:02:03.000Z], {:avro_primitive_type, "long", [{"logicalType", "timestamp-millis"}]}, "")
  {:ok, 1704070923000}

  iex> encode_value(~N[2010-01-13 23:00:07.005], {:avro_primitive_type, "long", [{"logicalType", "local-timestamp-micros"}]}, "")
  {:ok, 1263423607005000}

  iex> encode_value(~N[2024-01-13 11:00:03.123], {:avro_primitive_type, "long", [{"logicalType", "timestamp-micros"}]}, "")
  {:error, "not a datetime value"}

  iex> encode_value("67caff17-798d-4b70-b9d0-781d27382fdc", {:avro_primitive_type, "string", [{"logicalType", "uuid"}]}, "")
  {:ok, "67caff17-798d-4b70-b9d0-781d27382fdc"}

  iex> encode_value("not-a-uuid", {:avro_primitive_type, "string", [{"logicalType", "uuid"}]}, "")
  {:error, "not a uuid value"}

  ## Array types

  iex> encode_value(["one", "two"], {:avro_array_type, {:avro_primitive_type, "string", []}, []}, "")
  {:ok, ["one", "two"]}

  iex> encode_value(["one", 2], {:avro_array_type, {:avro_primitive_type, "string", []}, []}, "")
  {:error, "not a string value"}

  ## Map types

  iex> encode_value(%{"one" => 1, "two" => 2}, {:avro_map_type, {:avro_primitive_type, "int", []}, []}, "")
  {:ok, %{"one" => 1, "two" => 2}}

  iex> encode_value(%{"one" => 1, "two" => "2"}, {:avro_map_type, {:avro_primitive_type, "int", []}, []}, "")
  {:error, "not an integer value"}

  ## Union types

  iex> encode_value(
  ...>  nil,
  ...>  {:avro_union_type,
  ...>   {2,
  ...>    {1, {:avro_primitive_type, "string", [{"logicalType", "uuid"}]},
  ...>    {0, {:avro_primitive_type, "null", []}, nil, nil}, nil}},
  ...>   {2, {"string", {1, true}, {"null", {0, true}, nil, nil}, nil}}}, "")
  {:ok, nil}

  iex> encode_value(
  ...>  "d8d8d536-700d-4773-a950-90fdcd3ae686",
  ...>  {:avro_union_type,
  ...>   {2,
  ...>    {1, {:avro_primitive_type, "string", [{"logicalType", "uuid"}]},
  ...>    {0, {:avro_primitive_type, "null", []}, nil, nil}, nil}},
  ...>   {2, {"string", {1, true}, {"null", {0, true}, nil, nil}, nil}}}, "")
  {:ok, "d8d8d536-700d-4773-a950-90fdcd3ae686"}

  iex> encode_value(
  ...>  "not-a-uuid-or-nil",
  ...>  {:avro_union_type,
  ...>   {2,
  ...>    {1, {:avro_primitive_type, "string", [{"logicalType", "uuid"}]},
  ...>    {0, {:avro_primitive_type, "null", []}, nil, nil}, nil}},
  ...>   {2, {"string", {1, true}, {"null", {0, true}, nil, nil}, nil}}}, "")
  {:error, "no compatible type found"}


  ## Reference types

  iex> (fn ->
  ...>   Code.eval_string("defmodule MyPrefix.TestType do
  ...>     def to_avro(value), do: {:ok, value}
  ...>   end")
  ...>   encode_value("value", "TestType", "Elixir.MyPrefix")
  ...> end).()
  {:ok, "value"}

  iex> encode_value(%{}, "TestUnknownType", "Elixir")
  {:error, "unknown reference: TestUnknownType"}
  """
  @spec encode_value(any(), :avro.type_or_name(), module_prefix :: String.t()) ::
          {:ok, any()} | {:error, any()}
  def encode_value(value, {:avro_primitive_type, name, custom}, _module_prefix) do
    case List.keyfind(custom, "logicalType", 0) do
      nil ->
        validate_primitive(value, name)

      {"logicalType", logical_type} ->
        encode_logical(value, name, logical_type)
    end
  end

  def encode_value(values, {:avro_array_type, type, _custom}, module_prefix)
      when is_list(values) do
    Enum.reduce_while(values, {:ok, []}, fn value, {:ok, result} ->
      case encode_value(value, type, module_prefix) do
        {:ok, encoded} -> {:cont, {:ok, result ++ [encoded]}}
        error -> {:halt, error}
      end
    end)
  end

  def encode_value(values, {:avro_map_type, type, _custom}, module_prefix) when is_map(values) do
    Enum.reduce_while(values, {:ok, %{}}, fn {key, value}, {:ok, result} ->
      case encode_value(value, type, module_prefix) do
        {:ok, encoded} -> {:cont, {:ok, Map.put(result, key, encoded)}}
        error -> {:halt, error}
      end
    end)
  end

  def encode_value(value, {:avro_union_type, _id2type, _name2id} = union, module_prefix) do
    Enum.reduce_while(:avro_union.get_types(union), {:error, "no compatible type found"}, fn type,
                                                                                             res ->
      case encode_value(value, type, module_prefix) do
        {:ok, encoded} -> {:halt, {:ok, encoded}}
        _error -> {:cont, res}
      end
    end)
  end

  def encode_value(value, reference, module_prefix) when is_binary(reference) do
    module = Names.module_name!(reference, module_prefix)

    if function_exported?(module, :to_avro, 1) do
      module.to_avro(value)
    else
      {:error, "unknown reference: #{reference}"}
    end
  end

  def encode_value(_value, _type, _module_prefix), do: {:error, :not_supported}

  defp validate_primitive(value, "null") do
    if is_nil(value) do
      {:ok, value}
    else
      {:error, "not nil"}
    end
  end

  defp validate_primitive(value, "boolean") do
    if is_boolean(value) do
      {:ok, value}
    else
      {:error, "not a boolean value"}
    end
  end

  defp validate_primitive(value, "bytes") do
    if is_binary(value) do
      {:ok, value}
    else
      {:error, "not a binary value"}
    end
  end

  defp validate_primitive(value, "double") do
    if is_float(value) do
      if value >= -1.7_976_931_348_623_157e308 and value <= 1.7_976_931_348_623_157e308 do
        {:ok, value}
      else
        {:error, "value out of range"}
      end
    else
      {:error, "not a float value"}
    end
  end

  defp validate_primitive(value, "float") do
    if is_float(value) do
      if value >= -3.4_028_235e38 and value <= 3.4_028_235e38 do
        {:ok, value}
      else
        {:error, "value out of range"}
      end
    else
      {:error, "not a float value"}
    end
  end

  defp validate_primitive(value, "int") do
    if is_integer(value) do
      if value >= -2_147_483_648 and value <= 2_147_483_647 do
        {:ok, value}
      else
        {:error, "value out of range"}
      end
    else
      {:error, "not an integer value"}
    end
  end

  defp validate_primitive(value, "long") do
    if is_integer(value) do
      if value >= -9_223_372_036_854_775_808 and value <= 9_223_372_036_854_775_807 do
        {:ok, value}
      else
        {:error, "value out of range"}
      end
    else
      {:error, "not an integer value"}
    end
  end

  defp validate_primitive(value, "string") do
    if is_binary(value) do
      {:ok, value}
    else
      {:error, "not a string value"}
    end
  end

  defp encode_logical(value, "bytes", "decimal") do
    if Decimal.is_decimal(value) do
      {:error, "decimal encoding not implemented yet"}
    else
      {:error, "not a decimal value"}
    end
  end

  defp encode_logical(value, "int", "date") do
    case value do
      %Date{} -> {:ok, Date.diff(value, ~D[1970-01-01])}
      _ -> {:error, "not a date value"}
    end
  end

  defp encode_logical(value, "int", "time-millis") do
    case value do
      %Time{} ->
        {:ok, Time.diff(value, ~T[00:00:00.000], :millisecond)}

      _ ->
        {:error, "not a time value"}
    end
  end

  defp encode_logical(value, "long", "time-micros") do
    case value do
      %Time{} ->
        {:ok, Time.diff(value, ~T[00:00:00.000000], :microsecond)}

      _ ->
        {:error, "not a time value"}
    end
  end

  defp encode_logical(value, "long", "timestamp-millis") do
    case value do
      %DateTime{} ->
        {:ok, DateTime.to_unix(value, :millisecond)}

      _ ->
        {:error, "not a datetime value"}
    end
  end

  defp encode_logical(value, "long", "timestamp-micros") do
    case value do
      %DateTime{} ->
        {:ok, DateTime.to_unix(value, :microsecond)}

      _ ->
        {:error, "not a datetime value"}
    end
  end

  defp encode_logical(value, "long", "local-timestamp-millis") do
    case value do
      %NaiveDateTime{} ->
        {:ok, Timex.diff(value, ~N[1970-01-01 00:00:00.000000], :millisecond)}

      _ ->
        {:error, "not a naive datetime value"}
    end
  end

  defp encode_logical(value, "long", "local-timestamp-micros") do
    case value do
      %NaiveDateTime{} ->
        {:ok, Timex.diff(value, ~N[1970-01-01 00:00:00.000000], :microsecond)}

      _ ->
        {:error, "not a naive datetime value"}
    end
  end

  defp encode_logical(value, "string", "uuid") do
    case UUID.info(value) do
      {:ok, _} -> {:ok, value}
      _ -> {:error, "not a uuid value"}
    end
  end

  defp encode_logical(_value, primitive_type, logical_type) do
    {:error, "#{logical_type}[#{primitive_type}] encoding not implemented"}
  end

  @spec decode_value!(any(), :avro.type_or_name(), module_prefix :: String.t()) ::
          any() | no_return()
  def decode_value!(value, type, module_prefix) do
    case decode_value(value, type, module_prefix) do
      {:ok, value} -> value
      {:error, error} -> raise "Error during decoding of value: #{inspect(error)}"
    end
  end

  @doc ~S"""
  Decodes any avro value into its elixir format.

  # Examples

  ## Primitive types

  iex> decode_value(nil, {:avro_primitive_type, "null", []}, "")
  {:ok, nil}

  iex> decode_value(true, {:avro_primitive_type, "boolean", []}, "")
  {:ok, true}

  iex> decode_value(25, {:avro_primitive_type, "int", []}, "")
  {:ok, 25}

  iex> decode_value(2_147_483_648, {:avro_primitive_type, "int", []}, "")
  {:error, "value out of range"}

  iex> decode_value(19723, {:avro_primitive_type, "int", [{"logicalType", "date"}]}, "")
  {:ok, ~D[2024-01-01]}

  iex> decode_value(3661123, {:avro_primitive_type, "int", [{"logicalType", "time-millis"}]}, "")
  {:ok, ~T[01:01:01.123]}

  iex> decode_value(202.35, {:avro_primitive_type, "int", [{"logicalType", "date"}]}, "")
  {:error, "not an integer value"}

  iex> decode_value(25699000123, {:avro_primitive_type, "long", [{"logicalType", "time-micros"}]}, "")
  {:ok, ~T[07:08:19.000123]}

  iex> decode_value(1704070923000, {:avro_primitive_type, "long", [{"logicalType", "timestamp-millis"}]}, "")
  {:ok, ~U[2024-01-01 01:02:03.000Z]}

  iex> decode_value(1263423607005000, {:avro_primitive_type, "long", [{"logicalType", "local-timestamp-micros"}]}, "")
  {:ok, ~N[2010-01-13 23:00:07.005000]}

  iex> decode_value("2024-01-13 11:00:03.123", {:avro_primitive_type, "long", [{"logicalType", "timestamp-micros"}]}, "")
  {:error, "not an integer value"}

  iex> decode_value("67caff17-798d-4b70-b9d0-781d27382fdc", {:avro_primitive_type, "string", [{"logicalType", "uuid"}]}, "")
  {:ok, "67caff17-798d-4b70-b9d0-781d27382fdc"}

  iex> decode_value("not-a-uuid", {:avro_primitive_type, "string", [{"logicalType", "uuid"}]}, "")
  {:error, "not a uuid value"}

  ## Array types

  iex> decode_value(["one", "two"], {:avro_array_type, {:avro_primitive_type, "string", []}, []}, "")
  {:ok, ["one", "two"]}

  iex> decode_value(["one", 2], {:avro_array_type, {:avro_primitive_type, "string", []}, []}, "")
  {:error, "not a string value"}

  ## Map types

  iex> decode_value(%{"one" => 1, "two" => 2}, {:avro_map_type, {:avro_primitive_type, "int", []}, []}, "")
  {:ok, %{"one" => 1, "two" => 2}}

  iex> decode_value(%{"one" => 1, "two" => "2"}, {:avro_map_type, {:avro_primitive_type, "int", []}, []}, "")
  {:error, "not an integer value"}

  ## Union types

  iex> decode_value(
  ...>  nil,
  ...>  {:avro_union_type,
  ...>   {2,
  ...>    {1, {:avro_primitive_type, "string", [{"logicalType", "uuid"}]},
  ...>    {0, {:avro_primitive_type, "null", []}, nil, nil}, nil}},
  ...>   {2, {"string", {1, true}, {"null", {0, true}, nil, nil}, nil}}}, "")
  {:ok, nil}

  iex> decode_value(
  ...>  "d8d8d536-700d-4773-a950-90fdcd3ae686",
  ...>  {:avro_union_type,
  ...>   {2,
  ...>    {1, {:avro_primitive_type, "string", [{"logicalType", "uuid"}]},
  ...>    {0, {:avro_primitive_type, "null", []}, nil, nil}, nil}},
  ...>   {2, {"string", {1, true}, {"null", {0, true}, nil, nil}, nil}}}, "")
  {:ok, "d8d8d536-700d-4773-a950-90fdcd3ae686"}

  iex> decode_value(
  ...>  "not-a-uuid-or-nil",
  ...>  {:avro_union_type,
  ...>   {2,
  ...>    {1, {:avro_primitive_type, "string", [{"logicalType", "uuid"}]},
  ...>    {0, {:avro_primitive_type, "null", []}, nil, nil}, nil}},
  ...>   {2, {"string", {1, true}, {"null", {0, true}, nil, nil}, nil}}}, "")
  {:error, "no compatible type found"}

  """
  @spec decode_value(any(), :avro.type_or_name(), String.t()) :: {:ok, any()} | {:error, any()}
  def decode_value(value, {:avro_primitive_type, name, custom}, _module_prefix) do
    case List.keyfind(custom, "logicalType", 0) do
      nil ->
        validate_primitive(value, name)

      {"logicalType", logical_type} ->
        decode_logical(value, name, logical_type)
    end
  end

  def decode_value(values, {:avro_array_type, type, _custom}, module_prefix)
      when is_list(values) do
    Enum.reduce_while(values, {:ok, []}, fn value, {:ok, result} ->
      case decode_value(value, type, module_prefix) do
        {:ok, decoded} -> {:cont, {:ok, result ++ [decoded]}}
        error -> {:halt, error}
      end
    end)
  end

  def decode_value(values, {:avro_map_type, type, _custom}, module_prefix) when is_map(values) do
    Enum.reduce_while(values, {:ok, %{}}, fn {key, value}, {:ok, result} ->
      case decode_value(value, type, module_prefix) do
        {:ok, decoded} -> {:cont, {:ok, Map.put(result, key, decoded)}}
        error -> {:halt, error}
      end
    end)
  end

  def decode_value(value, {:avro_union_type, _id2type, _name2id} = union, module_prefix) do
    Enum.reduce_while(:avro_union.get_types(union), {:error, "no compatible type found"}, fn type,
                                                                                             res ->
      case decode_value(value, type, module_prefix) do
        {:ok, decoded} -> {:halt, {:ok, decoded}}
        _error -> {:cont, res}
      end
    end)
  end

  def decode_value(value, reference, module_prefix) when is_binary(reference) do
    module = Names.module_name!(reference, module_prefix)
    if function_exported?(module, :from_avro, 1) do
      module.from_avro(value)
    else
      {:error, "unknown reference: #{reference}"}
    end
  end

  defp decode_logical(_value, "bytes", "decimal") do
    {:error, "decimal decoding not implemented yet"}
  end

  defp decode_logical(value, "int", "date") do
    if is_integer(value) do
      {:ok, Date.add(~D[1970-01-01], value)}
    else
      {:error, "not an integer value"}
    end
  end

  defp decode_logical(value, "int", "time-millis") do
    if is_integer(value) do
      {:ok, Time.add(~T[00:00:00.000], value, :millisecond)}
    else
      {:error, "not an integer value"}
    end
  end

  defp decode_logical(value, "long", "time-micros") do
    if is_integer(value) do
      {:ok, Time.add(~T[00:00:00.000000], value, :microsecond)}
    else
      {:error, "not an integer value"}
    end
  end

  defp decode_logical(value, "long", "timestamp-millis") do
    if is_integer(value) do
      DateTime.from_unix(value, :millisecond)
    else
      {:error, "not an integer value"}
    end
  end

  defp decode_logical(value, "long", "timestamp-micros") do
    if is_integer(value) do
      DateTime.from_unix(value, :microsecond)
    else
      {:error, "not an integer value"}
    end
  end

  defp decode_logical(value, "long", "local-timestamp-millis") do
    if is_integer(value) do
      {:ok, Timex.add(~N[1970-01-01 00:00:00.000000], Timex.Duration.from_milliseconds(value))}
    else
      {:error, "not an integer value"}
    end
  end

  defp decode_logical(value, "long", "local-timestamp-micros") do
    if is_integer(value) do
      {:ok, Timex.add(~N[1970-01-01 00:00:00.000000], Timex.Duration.from_microseconds(value))}
    else
      {:error, "not an integer value"}
    end
  end

  defp decode_logical(value, "string", "uuid") do
    case UUID.info(value) do
      {:ok, _} -> {:ok, value}
      _ -> {:error, "not a uuid value"}
    end
  end

  defp decode_logical(_value, primitive_type, logical_type) do
    {:error, "#{logical_type}[#{primitive_type}] decoding not implemented"}
  end
end
