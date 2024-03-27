defmodule ElixirAvro.AvroType.Primitive do
  @moduledoc nil

  @behaviour ElixirAvro.AvroType

  alias ElixirAvro.AvroType

  @type t :: %__MODULE__{
          name: String.t(),
          custom_props: [AvroType.CustomProp.t()]
        }

  defstruct [:name, custom_props: []]

  @callback from_erl(:avro.avro_type() | :avro.record_field()) :: t()
  def from_erl({_, name, custom_props}) do
    %__MODULE__{
      name: name,
      custom_props: Enum.map(custom_props, &AvroType.CustomProp.from_erl/1)
    }
  end

  @doc ~S"""
  Returns the logical type or nil if the primitive type isn't a logical type.
  """
  @spec get_logical_type(t()) :: String.t() | nil
  def get_logical_type(%__MODULE__{custom_props: custom_props}) do
    logical_type = Enum.find(custom_props, &AvroType.CustomProp.logical_type?/1)

    case logical_type do
      nil -> nil
      %AvroType.CustomProp{value: logical_type} -> logical_type
    end
  end

  @doc ~S"""
  Validate the given value against the provided Avro type.

  # Examples

  NOTE: put here all the examples.
  """
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
