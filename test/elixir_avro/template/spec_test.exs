defmodule ElixirAvro.Template.SpecTest do
  use ExUnit.Case, async: true

  alias ElixirAvro.AvroType.Array
  alias ElixirAvro.AvroType.CustomProp
  alias ElixirAvro.AvroType.Fixed
  alias ElixirAvro.AvroType.Map
  alias ElixirAvro.AvroType.Primitive
  alias ElixirAvro.AvroType.Union

  doctest ElixirAvro.Template.Spec, import: true
end
