defmodule ElixirAvro.AvroType.Value.Encoder do
  @moduledoc """
  Encodes a value according to the provided Avro type.
  """

  alias ElixirAvro.AvroType
  alias ElixirAvro.AvroType.Array
  alias ElixirAvro.AvroType.Primitive
  alias ElixirAvro.AvroType.Union
  alias ElixirAvro.Template.Names

  alias Noether.Either

  require Decimal

  @doc ~S"""
  Encodes any value into an avro compatible format.

  # Examples

  ## Primitive types

  iex> encode_value!(true, %Primitive{name: "boolean"}, "")
  true

  iex> encode_value!(25, %Primitive{name: "int"}, "")
  25

  iex> encode_value!(2_147_483_648, %Primitive{name: "int"}, "")
  ** (ArgumentError) encode error: value out of range

  iex> encode_value!(~D[2024-01-01], %Primitive{name: "int", custom_props: [%CustomProp{name: "logicalType", value: "date"}]}, "")
  19723

  iex> encode_value!(~T[01:01:01.123], %Primitive{name: "int", custom_props: [%CustomProp{name: "logicalType", value: "time-millis"}]}, "")
  3661123

  iex> encode_value!(~T[04:05:06.001002], %Primitive{name: "int", custom_props: [%CustomProp{name: "logicalType", value: "date"}]}, "")
  ** (ArgumentError) encode error: not a date value

  iex> encode_value!(~T[07:08:19.000123], %Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "time-micros"}]}, "")
  25699000123

  iex> encode_value!(~U[2024-01-01 01:02:03.000Z], %Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "timestamp-millis"}]}, "")
  1704070923000

  iex> encode_value!(~N[2010-01-13 23:00:07.005], %Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "local-timestamp-micros"}]}, "")
  1263423607005000

  iex> encode_value!(~N[2024-01-13 11:00:03.123], %Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "timestamp-micros"}]}, "")
  ** (ArgumentError) encode error: not a datetime value

  iex> encode_value!("67caff17-798d-4b70-b9d0-781d27382fdc", %Primitive{name: "string", custom_props: [%CustomProp{name: "logicalType", value: "uuid"}]}, "")
  "67caff17-798d-4b70-b9d0-781d27382fdc"

  iex> encode_value!("not-a-uuid", %Primitive{name: "string", custom_props: [%CustomProp{name: "logicalType", value: "uuid"}]}, "")
  ** (ArgumentError) encode error: not a uuid value

  ## Array types

  iex> encode_value!(["one", "two"], %Array{type: %Primitive{name: "string"}}, "")
  ["one", "two"]

  iex> encode_value!(["one", 2], %Array{type: %Primitive{name: "string"}}, "")
  ** (ArgumentError) encode error: not a string value

  ## Map types

  iex> encode_value!(%{"one" => 1, "two" => 2}, %Map{type: %Primitive{name: "int"}}, "")
  %{"one" => 1, "two" => 2}

  iex> encode_value!(%{"one" => 1, "two" => "2"}, %Map{type: %Primitive{name: "int"}}, "")
  ** (ArgumentError) encode error: not an integer value

  ## Union types

  iex> encode_value!(
  ...>  nil,
  ...>  %Union{values: %{
  ...>    0 => %Primitive{name: "null"},
  ...>    1 => %Primitive{name: "string", custom_props: [%CustomProp{name: "logicalType", value: "uuid"}]}
  ...>  }}, "")
  nil

  iex> encode_value!(
  ...>  "d8d8d536-700d-4773-a950-90fdcd3ae686",
  ...>  %Union{values: %{
  ...>    0 => %Primitive{name: "null"},
  ...>    1 => %Primitive{name: "string", custom_props: [%CustomProp{name: "logicalType", value: "uuid"}]}
  ...>  }}, "")
  "d8d8d536-700d-4773-a950-90fdcd3ae686"

  iex> encode_value!(
  ...>  "not-a-uuid-or-nil",
  ...>  %Union{values: %{
  ...>    0 => %Primitive{name: "null"},
  ...>    1 => %Primitive{name: "string", custom_props: [%CustomProp{name: "logicalType", value: "uuid"}]}
  ...>  }}, "")
  ** (ArgumentError) encode error: no compatible type found


  ## Reference types

  iex> (fn ->
  ...>   Code.eval_string("defmodule MyPrefix.TestType do
  ...>     def to_avro(value), do: {:ok, value}
  ...>   end")
  ...>   encode_value!("value", "TestType", "Elixir.MyPrefix")
  ...> end).()
  "value"

  iex> encode_value!(%{}, "TestUnknownType", "Elixir")
  ** (ArgumentError) encode error: unknown reference: TestUnknownType
  """
  @spec encode_value!(any(), AvroType.t(), String.t()) :: any() | no_return()
  def encode_value!(value, type, module_prefix) do
    case encode_value(value, type, module_prefix) do
      {:ok, value} -> value
      {:error, error} -> raise ArgumentError, "encode error: #{error}"
    end
  end

  @spec encode_value(any(), AvroType.t(), String.t()) :: {:ok, any()} | {:error, any()}
  defp encode_value(value, %Primitive{name: name} = t, _) do
    case Primitive.get_logical_type(t) do
      nil -> Primitive.validate(value, name)
      logical_type -> encode_logical(value, name, logical_type)
    end
  end

  defp encode_value(values, %Array{type: type}, module_prefix) when is_list(values) do
    values
    |> Enum.reduce_while({:ok, []}, fn value, {:ok, result} ->
      case encode_value(value, type, module_prefix) do
        {:ok, encoded} -> {:cont, {:ok, [encoded | result]}}
        error -> {:halt, error}
      end
    end)
    |> Either.map(&Enum.reverse/1)
  end

  defp encode_value(values, %AvroType.Map{type: type}, module_prefix) when is_map(values) do
    Enum.reduce_while(values, {:ok, %{}}, fn {key, value}, {:ok, result} ->
      case encode_value(value, type, module_prefix) do
        {:ok, encoded} -> {:cont, {:ok, Map.put(result, key, encoded)}}
        error -> {:halt, error}
      end
    end)
  end

  defp encode_value(value, %Union{values: union_values}, module_prefix) do
    error = {:error, "no compatible type found"}

    Enum.reduce_while(union_values, error, fn {_id, type}, res ->
      case encode_value(value, type, module_prefix) do
        {:ok, encoded} -> {:halt, {:ok, encoded}}
        _ -> {:cont, res}
      end
    end)
  end

  defp encode_value(value, reference, module_prefix) when is_binary(reference) do
    module = reference |> Names.module_name!(module_prefix) |> String.to_atom()

    if function_exported?(module, :to_avro, 1) do
      module.to_avro(value)
    else
      {:error, "unknown reference: #{reference}"}
    end
  end

  defp encode_value(_, _, _), do: {:error, :not_supported}

  # Note: this should be divided and moved in another file to be handled with macros
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

  defp encode_logical(_, primitive_type, logical_type) do
    {:error, "#{logical_type}[#{primitive_type}] encoding not implemented"}
  end
end
