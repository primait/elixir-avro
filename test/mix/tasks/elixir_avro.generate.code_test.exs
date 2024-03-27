defmodule Mix.Tasks.ElixirAvro.Generate.CodeTest do
  use ExUnit.Case

  @target_path "test/mix/tasks/generated/"
  @schemas_path Path.join(__DIR__, "/schemas")
  @prefix "MyApp.AvroGenerated"
  @args %{target_path: @target_path, schemas_path: @schemas_path, prefix: @prefix}

  @generation_path "my_app/avro_generated/atp/players"
  @assertions_path "test/mix/tasks/modules/"

  @generated_files ["assistant.ex", "player_registered.ex", "trainer.ex"]

  # we could actually mock and do a unit test
  @tag :exclude
  test "mix generation task" do
    File.rm_rf(@target_path)

    :ok = ElixirAvro.Codegen.run(@args)

    files = @target_path |> Path.join(@generation_path) |> File.ls!() |> Enum.sort()

    assert @generated_files == files

    Enum.each(files, fn file ->
      generated_file_path = @target_path |> Path.join(@generation_path) |> Path.join(file)
      generated_content = File.read!(generated_file_path)
      IEx.Helpers.c(generated_file_path)

      asserted_content =
        @assertions_path |> Path.join(file) |> String.replace(".ex", "") |> File.read!()

      assert asserted_content == generated_content
    end)

    # Note: test here all generated modules functions
    trainer = MyApp.AvroGenerated.Atp.Players.Trainer
    trainer_name = "Trainer"

    assert {:ok, %_{fullname: ^trainer_name}} = trainer.from_avro(%{"fullname" => trainer_name})

    assert {:ok, %{"fullname" => ^trainer_name}} =
             trainer.to_avro(%{__struct__: trainer, fullname: trainer_name})
  end
end
