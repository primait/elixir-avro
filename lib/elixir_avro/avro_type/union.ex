defmodule ElixirAvro.AvroType.Union do
  @moduledoc nil

  @behaviour ElixirAvro.AvroType

  alias ElixirAvro.AvroType

  @type t :: %__MODULE__{
          values: %{non_neg_integer() => AvroType.t()}
        }

  defstruct [:values]

  @callback from_erl(:avro.avro_type() | :avro.record_field()) :: t()
  def from_erl({_, id2type, _}) do
    values =
      id2type
      |> :gb_trees.to_list()
      |> Enum.map(fn {id, type} -> {id, AvroType.from_erl(type)} end)
      |> Enum.into(%{})

    %__MODULE__{
      values: values
    }
  end
end
