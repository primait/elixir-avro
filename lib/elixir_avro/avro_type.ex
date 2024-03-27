defmodule ElixirAvro.AvroType do
  @moduledoc """
  Schema parser that gets Erl tuples (avro types) and transforms them into Elixir types.
  """

  alias ElixirAvro.AvroType.Array
  alias ElixirAvro.AvroType.Fixed
  alias ElixirAvro.AvroType.Map
  alias ElixirAvro.AvroType.Primitive
  alias ElixirAvro.AvroType.Record
  alias ElixirAvro.AvroType.Union

  alias ElixirAvro.AvroType.Enum, as: AvroEnum

  @type t ::
          Array.t()
          | Enum.t()
          | Fixed.t()
          | Map.t()
          | Primitive.t()
          | Record.t()
          | Union.t()
          | String.t()

  @type erlavro_type_name ::
          :avro_array_type
          | :avro_enum_type
          | :avro_fixed_type
          | :avro_map_type
          | :avro_primitive_type
          | :avro_record_type
          | :avro_union_type

  @callback from_erl(:avro.avro_type() | :avro.record_field() | String.t()) :: t()

  @spec from_erl(:avro.avro_type() | :avro.record_field() | String.t()) :: t()
  def from_erl(erl_type) when is_binary(erl_type), do: erl_type

  def from_erl(erl_type) do
    module = erl_type |> elem(0) |> to_module()
    module.from_erl(erl_type)
  end

  @spec to_module(erlavro_type_name()) :: atom()
  defp to_module(:avro_array_type), do: Array
  defp to_module(:avro_enum_type), do: AvroEnum
  defp to_module(:avro_fixed_type), do: Fixed
  defp to_module(:avro_map_type), do: Map
  defp to_module(:avro_primitive_type), do: Primitive
  defp to_module(:avro_record_type), do: Record
  defp to_module(:avro_union_type), do: Union
end
