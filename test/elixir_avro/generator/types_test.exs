defmodule ElixirAvro.Generator.TypesTest do
  use ExUnit.Case

  alias ElixirAvro.Generator.Types

  doctest ElixirAvro.Generator.Types, import: true

  test "encoding + decoding returns the initial value" do
    Enum.each(
      [
        {nil, {:avro_primitive_type, "null", []}},
        {true, {:avro_primitive_type, "boolean", []}},
        {25, {:avro_primitive_type, "int", []}},
        {Date.utc_today(), {:avro_primitive_type, "int", [{"logicalType", "date"}]}},
        {~T[01:01:01.123], {:avro_primitive_type, "int", [{"logicalType", "time-millis"}]}},
        {Time.utc_now(), {:avro_primitive_type, "long", [{"logicalType", "time-micros"}]}},
        {UUID.uuid4(), {:avro_primitive_type, "string", [{"logicalType", "uuid"}]}},
        {[UUID.uuid4(), UUID.uuid4()],
         {:avro_array_type, {:avro_primitive_type, "string", [{"logicalType", "uuid"}]}, []}}
      ],
      fn {value, type} ->
        assert {:ok, encoded} = Types.encode_value(value, type, "")
        assert {:ok, ^value} = Types.decode_value(encoded, type, "")
      end
    )
  end
end
