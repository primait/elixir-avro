defmodule ElixirAvro.AvroType.RecordField do
  @moduledoc nil

  alias ElixirAvro.AvroType

  @type t :: %__MODULE__{
          name: String.t(),
          type: AvroType.t(),
          doc: String.t(),
          # Note: this type need a refactor to include all the possibilities. For now we just skip it.
          default: :undefined | :avro.in() | :avro.avro_value(),
          order: :ascending | :descending | :ignore,
          aliases: [String.t()]
        }

  defstruct [
    :name,
    :type,
    :doc,
    :default,
    :order,
    :aliases
  ]

  @callback from_erl(:avro.avro_type() | :avro.record_field()) :: t()
  def from_erl({_, name, doc, type, :undefined = default, order, aliases}) do
    %__MODULE__{
      name: name,
      type: AvroType.from_erl(type),
      doc: doc,
      default: default,
      order: order,
      aliases: aliases
    }
  end

  def from_erl(record_field) do
    raise "default values in record field not implemented. \n#{inspect(record_field)}"
  end
end
