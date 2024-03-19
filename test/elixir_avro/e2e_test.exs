defmodule ElixirAvro.E2ETest do
  use ExUnit.Case

  defmodule AvroraClient do
    use Avrora.Client,
      schemas_path: Path.join(__DIR__, "e2e/schemas")
  end

  setup_all do
    {:ok, _pid} = AvroraClient.start_link()

    target_path = Path.join(__DIR__, "e2e/generated")
    File.rm_rf!(target_path)

    schemas_path = Path.join(__DIR__, "e2e/schemas")
    prefix = "MyApp.AvroGenerated"

    System.cmd("mix", ["elixir_avro.generate.code", target_path, schemas_path, prefix])

    generated_path = Path.join(target_path, "my_app/avro_generated/io/confluent")
    files = generated_path |> File.ls!() |> Enum.sort()

    assert files == [
             "all_types_example.ex",
             "example_enum.ex",
             "example_record.ex",
             "nested_enum.ex",
             "nested_record.ex"
           ]

    Enum.map(files, &Code.compile_file(Path.join(generated_path, &1)))

    Code.compile_file("test/elixir_avro/e2e/fixtures.exs")
  end

  test "encode and decode" do
    # We need to define a variable to reference modules just compiled
    # avoiding a warning about undefined module
    to_avro_map = ElixirAvro.E2E.Fixtures

    assert {:ok, avro_map} = to_avro_map.all_types_example(:map)

    assert {:ok, encoded} =
             AvroraClient.encode_plain(avro_map,
               schema_name: "AllTypesExample"
             )

    assert {:ok,
            %{
              "array_field" => ["item1", "item2", "item3"],
              "boolean_field" => true,
              "bytes_field" => <<1, 2, 3>>,
              "date_field" => 19_754,
              "double_field" => 2.71828,
              "enum_field" => "SYMBOL1",
              "float_field" => float_value,
              "int_field" => 42,
              "long_field" => 1_234_567_890,
              "map_field" => %{"key1" => 1, "key2" => 2, "key3" => 3},
              "null_field" => nil,
              "record_field" => %{
                "nested_enum" => "NESTED_SYMBOL2",
                "nested_int" => 123,
                "nested_record" => %{
                  "nested_enum" => "NESTED_SYMBOL1",
                  "nested_string" => "Nested Record String"
                },
                "nested_string" => "Nested String",
                "union_with_refs_field" => "SYMBOL1"
              },
              "string_field" => "Hello, Avro!",
              "timestamp_millis_field" => 1_704_070_923_000,
              "union_field" => 42,
              "uuid_field" => "34de4cfa-ced0-4b4a-bf2d-bd2e9283a40a"
            } = decoded} = AvroraClient.decode_plain(encoded, schema_name: "AllTypesExample")

    # Floats have rounding problems right now. I don't how to fix it in avrora.
    rounded_float = 3.14
    assert rounded_float == Float.round(float_value, 2)
    decoded = Map.put(decoded, "float_field", rounded_float)

    assert {:ok, to_avro_map.all_types_example(:struct)} ==
             to_avro_map.all_types_example(:from_avro, decoded)
  end

  test "encode and decode, array as union value" do
    # We need to define a variable to reference modules just compiled
    to_avro_map = ElixirAvro.E2E.Fixtures

    assert {:ok, avro_map} = to_avro_map.all_types_example2(:map)

    assert {:ok, encoded} =
             AvroraClient.encode_plain(avro_map,
               schema_name: "AllTypesExample"
             )

    assert {:ok,
            %{
              "array_field" => ["item1", "item2", "item3"],
              "boolean_field" => true,
              "bytes_field" => <<1, 2, 3>>,
              "date_field" => 19_754,
              "double_field" => 2.71828,
              "enum_field" => "SYMBOL1",
              "float_field" => _,
              "int_field" => 42,
              "long_field" => 1_234_567_890,
              "map_field" => %{"key1" => 1, "key2" => 2, "key3" => 3},
              "null_field" => nil,
              "record_field" => %{
                "nested_enum" => "NESTED_SYMBOL2",
                "nested_int" => 123,
                "nested_record" => %{
                  "nested_enum" => "NESTED_SYMBOL1",
                  "nested_string" => "Nested Record String"
                },
                "nested_string" => "Nested String",
                "union_with_refs_field" => "NESTED_SYMBOL1"
              },
              "string_field" => "Hello, Avro!",
              "timestamp_millis_field" => 1_704_070_923_000,
              "union_field" => [124, 1_000_001],
              "uuid_field" => "34de4cfa-ced0-4b4a-bf2d-bd2e9283a40a"
            }} = AvroraClient.decode_plain(encoded, schema_name: "AllTypesExample")
  end
end
