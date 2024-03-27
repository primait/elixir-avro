defmodule ElixirAvro.E2E.Fixtures do
  use ExUnit.Case

  def all_types_example(:struct) do
    union = 42
    union_with_refs = MyApp.AvroGenerated.Io.Confluent.ExampleEnum.symbol1()

    %MyApp.AvroGenerated.Io.Confluent.AllTypesExample{
      null_field: nil,
      boolean_field: true,
      int_field: 42,
      long_field: 1_234_567_890,
      float_field: 3.14,
      double_field: 2.71828,
      string_field: "Hello, Avro!",
      bytes_field: <<1, 2, 3>>,
      date_field: ~D[2024-02-01],
      uuid_field: "34de4cfa-ced0-4b4a-bf2d-bd2e9283a40a",
      timestamp_millis_field: ~U[2024-01-01 01:02:03.000Z],
      array_field: ["item1", "item2", "item3"],
      map_field: %{"key1" => 1, "key2" => 2, "key3" => 3},
      enum_field: MyApp.AvroGenerated.Io.Confluent.ExampleEnum.symbol1(),
      union_field: union,
      record_field: %MyApp.AvroGenerated.Io.Confluent.ExampleRecord{
        nested_string: "Nested String",
        nested_int: 123,
        nested_enum: MyApp.AvroGenerated.Io.Confluent.NestedEnum.nested_symbol2(),
        nested_record: %MyApp.AvroGenerated.Io.Confluent.NestedRecord{
          nested_string: "Nested Record String",
          nested_enum: MyApp.AvroGenerated.Io.Confluent.NestedEnum.nested_symbol1()
        },
        union_with_refs_field: union_with_refs
      }
    }
  end

  def all_types_example(:map) do
    :struct
    |> all_types_example()
    |> MyApp.AvroGenerated.Io.Confluent.AllTypesExample.to_avro()
  end

  def all_types_example(:from_avro, map) do
    MyApp.AvroGenerated.Io.Confluent.AllTypesExample.from_avro(map)
  end

  def all_types_example2(:map) do
    union = [124, 1_000_001]
    union_with_refs = MyApp.AvroGenerated.Io.Confluent.NestedEnum.nested_symbol1()

    MyApp.AvroGenerated.Io.Confluent.AllTypesExample.to_avro(
      %MyApp.AvroGenerated.Io.Confluent.AllTypesExample{
        null_field: nil,
        boolean_field: true,
        int_field: 42,
        long_field: 1_234_567_890,
        float_field: 3.14,
        double_field: 2.71828,
        string_field: "Hello, Avro!",
        bytes_field: <<1, 2, 3>>,
        date_field: ~D[2024-02-01],
        uuid_field: "34de4cfa-ced0-4b4a-bf2d-bd2e9283a40a",
        timestamp_millis_field: ~U[2024-01-01 01:02:03.000Z],
        array_field: ["item1", "item2", "item3"],
        map_field: %{"key1" => 1, "key2" => 2, "key3" => 3},
        enum_field: MyApp.AvroGenerated.Io.Confluent.ExampleEnum.symbol1(),
        union_field: union,
        record_field: %MyApp.AvroGenerated.Io.Confluent.ExampleRecord{
          nested_string: "Nested String",
          nested_int: 123,
          nested_enum: MyApp.AvroGenerated.Io.Confluent.NestedEnum.nested_symbol2(),
          nested_record: %MyApp.AvroGenerated.Io.Confluent.NestedRecord{
            nested_string: "Nested Record String",
            nested_enum: MyApp.AvroGenerated.Io.Confluent.NestedEnum.nested_symbol1()
          },
          union_with_refs_field: union_with_refs
        }
      }
    )
  end
end
