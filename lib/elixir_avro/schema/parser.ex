defmodule ElixirAvro.Schema.Parser do
  @moduledoc """
  Schema parser that uses erlavro and ets to store decoded schemas.
  """

  alias ElixirAvro.Schema

  # avoid to overwrite same types and break if the definitions are different, check if add_type already does it
  # apparently there is `allow_type_redefine`, let's test if it works as expected

  # This is not pure, since it uses ets underneath,
  # but with some effort we can make it pure if we really want to.
  @spec parse(String.t(), (String.t() -> String.t())) :: Schema.Record.t() | Schema.Enum.t()
  def parse(root_schema_content, read_schema_fun) do
    erlavro_schema_parsed =
      :avro_json_decoder.decode_schema(root_schema_content, allow_bad_references: true)

    lookup_table = :avro_schema_store.new()
    :avro_schema_store.add_type(erlavro_schema_parsed, lookup_table)

    add_references_types(erlavro_schema_parsed, lookup_table, read_schema_fun)

    :avro_schema_store.get_all_types(lookup_table)
    |> Enum.map(&{:avro.get_type_fullname(&1), &1})
    |> Enum.into(%{})
  end

  defp add_references_types(erlavro_schema_parsed, lookup_table, read_schema_fun) do
    {:ok, refs} =
      Avrora.Schema.ReferenceCollector.collect(erlavro_schema_parsed)

    refs
    |> Enum.map(&lookup_type(&1, read_schema_fun, lookup_table))
    |> Enum.map(&:avro_schema_store.add_type(&1, lookup_table))
  end

  defp lookup_type(ref, read_schema_fun, lookup_table) do
    looked_up = :avro_schema_store.lookup_type(ref, lookup_table)
    # TODO write a test for the edge cases
    if looked_up do
      {:ok, type} = looked_up
      type
    else
      ref
      |> read_schema_fun.()
      |> :avro_json_decoder.decode_schema(allow_bad_references: true)
    end
  end
end
