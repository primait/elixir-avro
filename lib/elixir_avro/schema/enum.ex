defmodule ElixirAvro.Schema.Enum do
  @moduledoc nil

  @type t :: %__MODULE__{
          name: String.t(),
          namespace: String.t(),
          aliases: [],
          doc: String.t(),
          symbols: [String.t()],
          fullname: String.t(),
          custom: []
        }

  defstruct [:name, :namespace, :aliases, :doc, :symbols, :fullname, custom: []]

  @spec from_tuple({
          :avro_enum_type,
          String.t(),
          String.t(),
          [],
          String.t(),
          [String.t()],
          String.t(),
          []
        }) :: t()
  def from_tuple({:avro_enum_type, name, namespace, aliases, doc, symbols, fullname, custom}) do
    %__MODULE__{
      name: name,
      namespace: namespace,
      aliases: aliases,
      doc: doc,
      symbols: symbols,
      fullname: fullname,
      custom: custom
    }
  end
end
