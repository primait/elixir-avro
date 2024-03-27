defmodule ElixirAvro.Schema.Parser do
  @moduledoc false

  alias ElixirAvro.AvroType

  @spec from_erl_types([:avro.avro_type() | :avro.record_field() | String.t()]) :: [AvroType.t()]
  def from_erl_types(erl_types), do: Enum.map(erl_types, &AvroType.from_erl/1)
end
