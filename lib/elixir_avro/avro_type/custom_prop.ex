defmodule ElixirAvro.AvroType.CustomProp do
  @moduledoc nil

  @type t :: %__MODULE__{
          name: String.t(),
          value: :jsone.json_value()
        }

  defstruct [:name, :value]

  @callback from_erl(:avro.avro_type() | :avro.record_field()) :: t()
  def from_erl({name, value}) do
    %__MODULE__{
      name: name,
      value: value
    }
  end

  @spec logical_type?(t()) :: boolean
  def logical_type?(%__MODULE__{name: "logicalType"}), do: true
  def logical_type?(%__MODULE__{}), do: false
end
