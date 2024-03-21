defmodule Mix.Tasks.ElixirAvro.Generate.CodeTest do
  use ExUnit.Case

  # we could actually mock and do a unit test
  @tag :exclude
  test "mix generation task" do
    target_path = "test/mix/tasks/generated/"
    schemas_path = Path.join(__DIR__, "/schemas")
    prefix = "MyApp.AvroGenerated"

    System.cmd("mix", ["elixir_avro.generate.code", target_path, schemas_path, prefix])

    ["player_registered.ex", "trainer.ex"] =
      File.ls!(Path.join(target_path, "my_app/avro_generated/atp/players")) |> Enum.sort()

    # TODO here we could test also for the content
  end
end
