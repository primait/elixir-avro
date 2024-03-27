defmodule ElixirAvro.AvroType.Record do
  @moduledoc nil

  alias ElixirAvro.AvroType

  @behaviour AvroType

  @type t :: %__MODULE__{
          name: String.t(),
          fullname: String.t(),
          namespace: String.t(),
          doc: String.t(),
          fields: [AvroType.RecordField.t()],
          aliases: [],
          custom_props: [AvroType.CustomProp.t()]
        }

  defstruct [
    :name,
    :fullname,
    :namespace,
    :doc,
    :fields,
    :aliases,
    custom_props: []
  ]

  @callback from_erl(:avro.avro_type() | :avro.record_field()) :: t()
  def from_erl({_, name, namespace, doc, aliases, fields, fullname, custom_props}) do
    %__MODULE__{
      name: name,
      fullname: fullname,
      namespace: namespace,
      doc: doc,
      fields: Enum.map(fields, &AvroType.RecordField.from_erl/1),
      aliases: aliases,
      custom_props: Enum.map(custom_props, &AvroType.CustomProp.from_erl/1)
    }
  end
end
