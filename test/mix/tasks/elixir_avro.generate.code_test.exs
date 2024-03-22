defmodule Mix.Tasks.ElixirAvro.Generate.CodeTest do
  use ExUnit.Case

  alias Mix.Tasks.ElixirAvro.Generate.Code, as: ElixirAvroGenerator

  @target_path "test/mix/tasks/generated/"
  @schemas_path Path.join(__DIR__, "/schemas")
  @prefix "MyApp.AvroGenerated"
  @args ["-t", @target_path, "-s", @schemas_path, "-p", @prefix]

  @generation_path "my_app/avro_generated/atp/players"
  @assertions_path "test/mix/tasks/modules/"

  @generated_files ["assistant.ex", "player_registered.ex", "trainer.ex"]

  # we could actually mock and do a unit test
  @tag :exclude
  test "mix generation task" do
    File.rm_rf(@target_path)

    :ok = ElixirAvroGenerator.run(@args)

    files = @target_path |> Path.join(@generation_path) |> File.ls!() |> Enum.sort()

    assert @generated_files == files

    Enum.map(files, fn file ->
      generated_content = @target_path |> Path.join(@generation_path) |> Path.join(file) |> File.read!()
      asserted_content = @assertions_path |> Path.join(file) |> String.replace(".ex", "") |> File.read!()
      assert asserted_content == generated_content
    end)
  end
end
