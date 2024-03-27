defmodule ElixirAvro.AvroType.Value.DecoderTest do
  use ExUnit.Case, async: true

  alias ElixirAvro.AvroType.Array
  alias ElixirAvro.AvroType.CustomProp
  alias ElixirAvro.AvroType.Map
  alias ElixirAvro.AvroType.Primitive
  alias ElixirAvro.AvroType.Union

  doctest ElixirAvro.AvroType.Value.Decoder, import: true
end
