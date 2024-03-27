defmodule ElixirAvro.AvroType.Enum do
  @moduledoc nil

  @behaviour ElixirAvro.AvroType

  alias ElixirAvro.AvroType

  @type t :: %__MODULE__{
          name: String.t(),
          fullname: String.t(),
          namespace: String.t(),
          doc: String.t(),
          symbols: [String.t()],
          aliases: [String.t()],
          custom_props: [AvroType.CustomProp.t()]
        }

  defstruct [
    :name,
    :fullname,
    :namespace,
    :doc,
    :symbols,
    :aliases,
    custom_props: []
  ]

  @callback from_erl(:avro.avro_type() | :avro.record_field()) :: t()
  def from_erl({_, name, namespace, aliases, doc, symbols, fullname, custom_props}) do
    %__MODULE__{
      name: name,
      fullname: fullname,
      namespace: namespace,
      doc: doc,
      symbols: symbols,
      aliases: aliases,
      custom_props: Enum.map(custom_props, &AvroType.CustomProp.from_erl/1)
    }
  end
end
