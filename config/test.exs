import Config

config :elixir_avro, :custom_logical_types, %{
    {"string", "test-logical"} => ElixirAvro.AvroType.TestLogical
}
