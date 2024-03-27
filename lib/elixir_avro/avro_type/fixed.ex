defmodule ElixirAvro.AvroType.Fixed do
  @moduledoc nil

  alias ElixirAvro.AvroType

  @behaviour AvroType

  @type t :: %__MODULE__{
          name: String.t(),
          fullname: String.t(),
          namespace: String.t(),
          size: pos_integer(),
          aliases: [String.t()],
          custom_props: [AvroType.CustomProp.t()]
        }

  defstruct [
    :name,
    :fullname,
    :namespace,
    :size,
    :aliases,
    custom_props: []
  ]

  @callback from_erl(:avro.avro_type() | :avro.record_field()) :: t()
  def from_erl({_, name, namespace, aliases, size, fullname, custom_props}) do
    %__MODULE__{
      name: name,
      fullname: fullname,
      namespace: namespace,
      size: size,
      aliases: aliases,
      custom_props: Enum.map(custom_props, &AvroType.CustomProp.from_erl/1)
    }
  end
end
