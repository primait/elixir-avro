defmodule ElixirAvro.AvroType.Primitive do
  @moduledoc nil

  @behaviour ElixirAvro.AvroType

  alias ElixirAvro.AvroType

  @type t :: %__MODULE__{
          name: String.t(),
          custom_props: [AvroType.CustomProp.t()]
        }

  defstruct [:name, custom_props: []]

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

  @callback from_erl(:avro.avro_type() | :avro.record_field()) :: t()
  def from_erl({_, name, custom_props}) do
    %__MODULE__{
      name: name,
      custom_props: Enum.map(custom_props, &AvroType.CustomProp.from_erl/1)
    }
  end

  @doc ~S"""
  Decode a primitive value. It can either decode a logical type or validate a primitive one.

  ## Examples
  iex> decode(nil, %Primitive{name: "null"})
  {:ok, nil}

  iex> decode(true, %Primitive{name: "boolean"})
  {:ok, true}

  iex> decode(25, %Primitive{name: "int"})
  {:ok, 25}

  iex> decode(2_147_483_648, %Primitive{name: "int"})
  {:error, "value out of range"}

  iex> decode(19723, %Primitive{name: "int", custom_props: [%CustomProp{name: "logicalType", value: "date"}]})
  {:ok, ~D[2024-01-01]}

  iex> decode(3661123, %Primitive{name: "int", custom_props: [%CustomProp{name: "logicalType", value: "time-millis"}]})
  {:ok, ~T[01:01:01.123]}

  iex> decode(202.35, %Primitive{name: "int", custom_props: [%CustomProp{name: "logicalType", value: "date"}]})
  {:error, "not an integer value"}

  iex> decode(25699000123, %Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "time-micros"}]})
  {:ok, ~T[07:08:19.000123]}

  iex> decode(1704070923000, %Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "timestamp-millis"}]})
  {:ok, ~U[2024-01-01 01:02:03.000Z]}

  iex> decode(1263423607005000, %Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "local-timestamp-micros"}]})
  {:ok, ~N[2010-01-13 23:00:07.005000]}

  iex> decode("2024-01-13 11:00:03.123", %Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "timestamp-micros"}]})
  {:error, "not an integer value"}

  iex> decode("67caff17-798d-4b70-b9d0-781d27382fdc", %Primitive{name: "string", custom_props: [%CustomProp{name: "logicalType", value: "uuid"}]})
  {:ok, "67caff17-798d-4b70-b9d0-781d27382fdc"}

  iex> decode("not-a-uuid", %Primitive{name: "string", custom_props: [%CustomProp{name: "logicalType", value: "uuid"}]})
  {:error, "not a uuid value"}
  """
  @spec decode(any(), t()) :: {:ok, any()} | {:error, String.t()}
  def decode(value, %__MODULE__{name: name, custom_props: custom_props}) do
    logical_types = Enum.filter(custom_props, &AvroType.CustomProp.logical_type?/1)

    case logical_types do
      [] ->
        validate(value, name)

      [%AvroType.CustomProp{value: logical_type}] ->
        AvroType.LogicalType.decode(value, name, logical_type)

      [_ | _] ->
        {:error, "more than one logical type found while decoding value"}
    end
  end

  @doc ~S"""

  # Examples
  iex> encode_value!(true, %Primitive{name: "boolean"})
  {:ok, true}

  iex> encode_value!(25, %Primitive{name: "int"})
  {:ok, 25}

  iex> encode_value!(2_147_483_648, %Primitive{name: "int"})
  {:error, "value out of range"}

  iex> encode_value!(~D[2024-01-01], %Primitive{name: "int", custom_props: [%CustomProp{name: "logicalType", value: "date"}]})
  {:ok, 19723}

  iex> encode_value!(~T[01:01:01.123], %Primitive{name: "int", custom_props: [%CustomProp{name: "logicalType", value: "time-millis"}]})
  {:ok, 3661123}

  iex> encode_value!(~T[04:05:06.001002], %Primitive{name: "int", custom_props: [%CustomProp{name: "logicalType", value: "date"}]})
  {:error, "not a date value"}

  iex> encode_value!(~T[07:08:19.000123], %Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "time-micros"}]})
  {:ok, 25699000123}

  iex> encode_value!(~U[2024-01-01 01:02:03.000Z], %Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "timestamp-millis"}]})
  {:ok, 1704070923000}

  iex> encode_value!(~N[2010-01-13 23:00:07.005], %Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "local-timestamp-micros"}]})
  {:ok, 1263423607005000}

  iex> encode_value!(~N[2024-01-13 11:00:03.123], %Primitive{name: "long", custom_props: [%CustomProp{name: "logicalType", value: "timestamp-micros"}]})
  {:error, "not a datetime value"}

  iex> encode_value!("67caff17-798d-4b70-b9d0-781d27382fdc", %Primitive{name: "string", custom_props: [%CustomProp{name: "logicalType", value: "uuid"}]})
  {:ok, "67caff17-798d-4b70-b9d0-781d27382fdc"}

  iex> encode_value!("not-a-uuid", %Primitive{name: "string", custom_props: [%CustomProp{name: "logicalType", value: "uuid"}]})
  {:error, "not a uuid value"}
  """
  @spec encode(any(), AvroType.t()) :: {:ok, any()} | {:error, any()}
  def encode(value, %__MODULE__{name: name, custom_props: custom_props}) do
    logical_types = Enum.filter(custom_props, &AvroType.CustomProp.logical_type?/1)

    case logical_types do
      [] ->
        validate(value, name)

      [%AvroType.CustomProp{value: logical_type}] ->
        AvroType.LogicalType.encode(value, name, logical_type)

      [_ | _] ->
        {:error, "more than one logical type found while encoding value"}
    end
  end

  @spec to_typedstruct_spec!(AvroType.t()) :: String.t() | no_return()
  def to_typedstruct_spec!(%__MODULE__{name: name, custom_props: custom_props}) do
    logical_types = Enum.filter(custom_props, &AvroType.CustomProp.logical_type?/1)

    case logical_types do
      [] ->
        case Map.get(@primitive_type_spec_strings, name) do
          nil -> raise ArgumentError, message: "unsupported type: #{inspect(name)}"
          type -> type
        end

      [%AvroType.CustomProp{value: logical_type}] ->
        AvroType.LogicalType.to_typedstruct_spec!(name, logical_type)

      [_ | _] ->
        {:error, "more than one logical type found while encoding value"}
    end
  end

  @spec validate(any(), String.t()) :: {:ok, any()} | {:error, String.t()}
  def validate(value, "null") do
    if is_nil(value) do
      {:ok, value}
    else
      {:error, "not nil"}
    end
  end

  def validate(value, "boolean") do
    if is_boolean(value) do
      {:ok, value}
    else
      {:error, "not a boolean value"}
    end
  end

  def validate(value, "bytes") do
    if is_binary(value) do
      {:ok, value}
    else
      {:error, "not a binary value"}
    end
  end

  def validate(value, "double") do
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

  def validate(value, "float") do
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

  def validate(value, "int") do
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

  def validate(value, "long") do
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

  def validate(value, "string") do
    if is_binary(value) do
      {:ok, value}
    else
      {:error, "not a string value"}
    end
  end
end
