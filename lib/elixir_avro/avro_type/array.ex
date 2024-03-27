defmodule ElixirAvro.AvroType.Array do
  @moduledoc nil

  alias ElixirAvro.AvroType

  @behaviour AvroType

  @type t :: %__MODULE__{
          type: AvroType.t(),
          custom_props: [AvroType.CustomProp.t()]
        }

  defstruct [:type, custom_props: []]

  @callback from_erl(:avro.avro_type() | :avro.record_field()) :: t()
  def from_erl({_, type, custom_props}) do
    %__MODULE__{
      type: AvroType.from_erl(type),
      custom_props: Enum.map(custom_props, &AvroType.CustomProp.from_erl/1)
    }
  end
end
