defmodule ElixirAvro.Schema.Resolver do
  @moduledoc """
  Schema resolver that uses erlavro and ets to resolve reference types.
  """

  alias Avrora.Schema.ReferenceCollector

  @type opts :: [allow_bad_references: boolean()] | []

  @spec resolve_types([String.t()], opts) :: [:avro.avro_type()]
  def resolve_types(schema_contents, opts \\ [allow_bad_references: true]) do
    :ok = validate_schemas_format(schema_contents)

    lookup_table = :avro_schema_store.new()

    # Decoding schemas
    erlavro_schemas = Enum.map(schema_contents, &:avro_json_decoder.decode_schema(&1, opts))

    # Adding types to avro schema store
    Enum.each(erlavro_schemas, &:avro_schema_store.add_type(&1, lookup_table))

    erlavro_schemas
    |> Enum.flat_map(&collect_references/1)
    |> Enum.each(&resolve_reference(&1, lookup_table))

    :avro_schema_store.get_all_types(lookup_table)
  end

  @spec validate_schemas_format([String.t()]) :: :ok | no_return
  defp validate_schemas_format(schema_contents) do
    Enum.each(schema_contents, fn schema_content ->
      decode_result =
        schema_content
        |> String.trim()
        |> :jsone.try_decode()

      case decode_result do
        {:ok, _, ""} -> :ok
        _ -> exit("one or more provided avro schemas isn't a well formatted json")
      end
    end)
  end

  @spec collect_references(String.t()) :: [String.t()] | no_return
  defp collect_references(schema_content) do
    case ReferenceCollector.collect(schema_content) do
      {:ok, references} -> references
      {:error, term} -> exit("failed to collect references from schema #{inspect(term)}")
    end
  end

  @spec resolve_reference(String.t(), :avro_schema_store.store()) :: :ok | no_return
  def resolve_reference(reference, lookup_table) do
    case :avro_schema_store.lookup_type(reference, lookup_table) do
      {:ok, type} -> :avro_schema_store.add_type(type, lookup_table)
      _ -> exit("reference '#{reference}' not found")
    end

    :ok
  end
end
