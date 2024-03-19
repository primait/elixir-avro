defmodule ElixirAvro.Schema.Record do
  @moduledoc nil

  @type t :: %__MODULE__{
          name: String.t(),
          namespace: String.t(),
          doc: String.t(),
          aliases: [],
          fields: [tuple],
          fullname: String.t(),
          custom: []
        }

  defstruct [:name, :namespace, :doc, :aliases, :fields, :fullname, custom: []]

  @spec from_tuple({
          :avro_record_type,
          String.t(),
          String.t(),
          String.t(),
          [],
          [tuple],
          String.t(),
          []
        }) :: t()
  def from_tuple({:avro_record_type, name, namespace, doc, aliases, fields, fullname, custom}) do
    %__MODULE__{
      name: name,
      namespace: namespace,
      doc: doc,
      aliases: aliases,
      fields: fields,
      fullname: fullname,
      custom: custom
    }
  end
end
