defmodule ElixirAvro.Schema.ResolverTest do
  use ExUnit.Case

  alias ElixirAvro.Schema.Resolver

  @schemas_path "test/elixir_avro/schema_parser/schemas"

  describe "inline types" do
    test "record" do
      expected = %{
        "atp.players.PlayerRegistered" => player_registered_erlavro(),
        "atp.players.Trainer" => trainer_nested_erlavro()
      }

      types = resolve_types(schema())

      assert expected == types
    end

    test "enum" do
      expected = %{
        "atp.players.Trainer" => trainer_with_enum(),
        "atp.players.trainers.TrainerLevel" => trainer_level_erlavro()
      }

      types = resolve_types(schema4())

      assert expected == types
    end
  end

  describe "cross references" do
    test "record" do
      expected = %{
        "atp.players.PlayerRegistered" => player_registered_erlavro(),
        "atp.players.Trainer" => trainer_ref_erlavro()
      }

      types = resolve_types([schema2(), File.read!("#{@schemas_path}/trainer.avsc")])

      assert expected == types
    end

    test "enum" do
      expected = %{
        "atp.players.Trainer" => trainer_with_enum(),
        "atp.players.trainers.TrainerLevel" => trainer_level_erlavro()
      }

      types = resolve_types([schema5(), File.read!("#{@schemas_path}/trainer_level.avsc")])

      assert expected == types
    end

    test "cross reference to the current schema" do
      expected = %{
        "atp.players.Trainer" => trainer_with_same_enum_inline_and_as_ref(),
        "atp.players.trainers.TrainerLevel" => trainer_level_erlavro()
      }

      types = resolve_types(schema6())

      assert expected == types
    end
  end

  describe "mixed inline and cross" do
    test "two levels of nested records" do
      expected = %{
        "atp.players.PlayerRegisteredTwoLevelsNestingRecords" => player_registered2_erlavro(),
        "atp.players.Trainer" => trainer_nested_erlavro(),
        "atp.players.info.BirthInfo" => birth_info_erlavro(),
        "atp.players.info.Person" => person_erlavro()
      }

      types = resolve_types(schema3())

      assert expected == types
    end
  end

  @spec resolve_types(String.t() | [String.t()]) :: map()
  defp resolve_types(schema) when is_binary(schema), do: resolve_types([schema])

  defp resolve_types(schemas) do
    schemas
    |> Resolver.resolve_types()
    |> Enum.map(&{:avro.get_type_fullname(&1), &1})
    |> Enum.into(%{})
  end

  defp birth_info_erlavro() do
    {
      :avro_record_type,
      "BirthInfo",
      "atp.players.info",
      "Info about a player's birth.",
      [],
      [
        {:avro_record_field, "birthday", "",
         {:avro_primitive_type, "int", [{"logicalType", "date"}]}, :undefined, :ascending, []},
        {:avro_record_field, "father", "Father's info.", "atp.players.info.Person", :undefined,
         :ascending, []}
      ],
      "atp.players.info.BirthInfo",
      []
    }
  end

  defp person_erlavro() do
    {
      :avro_record_type,
      "Person",
      "",
      "",
      [],
      [
        {:avro_record_field, "fullname", "", {:avro_primitive_type, "string", []}, :undefined,
         :ascending, []},
        {:avro_record_field, "age", "", {:avro_primitive_type, "int", []}, :undefined, :ascending,
         []}
      ],
      "atp.players.info.Person",
      []
    }
  end

  defp trainer_nested_erlavro() do
    # Note: here we don't have an explicit namespace since it is inherited by the parent type
    {:avro_record_type, "Trainer", "", "A player trainer.", [],
     [
       {:avro_record_field, "fullname", "Full name of the trainer.",
        {:avro_primitive_type, "string", []}, :undefined, :ascending, []}
     ], "atp.players.Trainer", []}
  end

  defp trainer_ref_erlavro() do
    # Note: here we have an explicit namespace since the schema is defined in its own file
    {
      :avro_record_type,
      "Trainer",
      "atp.players",
      "A player trainer.",
      [],
      [
        {:avro_record_field, "fullname", "Full name of the trainer.",
         {:avro_primitive_type, "string", []}, :undefined, :ascending, []}
      ],
      "atp.players.Trainer",
      []
    }
  end

  defp player_registered_erlavro() do
    {:avro_record_type, "PlayerRegistered", "atp.players",
     "A new player is registered in the atp ranking system.", [],
     [
       {:avro_record_field, "player_id", "The unique identifier of the registered player (UUID).",
        {:avro_primitive_type, "string", [{"logicalType", "uuid"}]}, :undefined, :ascending, []},
       {:avro_record_field, "full_name", "The full name of the registered player.",
        {:avro_primitive_type, "string", []}, :undefined, :ascending, []},
       {:avro_record_field, "rank",
        "The current ranking of the registered player, start counting from 1.",
        {:avro_primitive_type, "int", []}, :undefined, :ascending, []},
       {:avro_record_field, "registration_date",
        "The date when the player was registered (number of UTC days from the unix epoch).",
        {:avro_primitive_type, "int", [{"logicalType", "date"}]}, :undefined, :ascending, []},
       {:avro_record_field, "sponsor_name", "The name of the current sponsor (optional).",
        {:avro_union_type,
         {2,
          {1, {:avro_primitive_type, "string", []},
           {0, {:avro_primitive_type, "null", []}, nil, nil}, nil}},
         {2, {"string", {1, true}, {"null", {0, true}, nil, nil}, nil}}}, :undefined, :ascending,
        []},
       {:avro_record_field, "trainer", "Current trainer.", "atp.players.Trainer", :undefined,
        :ascending, []}
     ], "atp.players.PlayerRegistered", []}
  end

  defp player_registered2_erlavro() do
    {
      :avro_record_type,
      "PlayerRegisteredTwoLevelsNestingRecords",
      "atp.players",
      "A new player is registered in the atp ranking system.",
      [],
      [
        {:avro_record_field, "player_id",
         "The unique identifier of the registered player (UUID).",
         {:avro_primitive_type, "string", [{"logicalType", "uuid"}]}, :undefined, :ascending, []},
        {:avro_record_field, "full_name", "The full name of the registered player.",
         {:avro_primitive_type, "string", []}, :undefined, :ascending, []},
        {:avro_record_field, "rank",
         "The current ranking of the registered player, start counting from 1.",
         {:avro_primitive_type, "int", []}, :undefined, :ascending, []},
        {:avro_record_field, "registration_date",
         "The date when the player was registered (number of UTC days from the unix epoch).",
         {:avro_primitive_type, "int", [{"logicalType", "date"}]}, :undefined, :ascending, []},
        {:avro_record_field, "sponsor_name", "The name of the current sponsor (optional).",
         {:avro_union_type,
          {2,
           {1, {:avro_primitive_type, "string", []},
            {0, {:avro_primitive_type, "null", []}, nil, nil}, nil}},
          {2, {"string", {1, true}, {"null", {0, true}, nil, nil}, nil}}}, :undefined, :ascending,
         []},
        {:avro_record_field, "trainer", "Current trainer.", "atp.players.Trainer", :undefined,
         :ascending, []},
        {:avro_record_field, "birth_info", "", "atp.players.info.BirthInfo", :undefined,
         :ascending, []}
      ],
      "atp.players.PlayerRegisteredTwoLevelsNestingRecords",
      []
    }
  end

  # Note: where is the enum?
  defp trainer_with_enum() do
    {
      :avro_record_type,
      "Trainer",
      "atp.players",
      "A player trainer.",
      [],
      [
        {:avro_record_field, "fullname", "Full name of the trainer.",
         {:avro_primitive_type, "string", []}, :undefined, :ascending, []},
        {:avro_record_field, "level", "", "atp.players.trainers.TrainerLevel", :undefined,
         :ascending, []}
      ],
      "atp.players.Trainer",
      []
    }
  end

  defp trainer_with_same_enum_inline_and_as_ref() do
    {
      :avro_record_type,
      "Trainer",
      "atp.players",
      "A player trainer.",
      [],
      [
        {:avro_record_field, "fullname", "Full name of the trainer.",
         {:avro_primitive_type, "string", []}, :undefined, :ascending, []},
        {:avro_record_field, "atp_level", "Trainer certified level by ATP.",
         "atp.players.trainers.TrainerLevel", :undefined, :ascending, []},
        {:avro_record_field, "fit_level", "Trainer certified level by FIT.",
         "atp.players.trainers.TrainerLevel", :undefined, :ascending, []}
      ],
      "atp.players.Trainer",
      []
    }
  end

  defp trainer_level_erlavro() do
    {:avro_enum_type, "TrainerLevel", "atp.players.trainers", [], "Trainer certified level.",
     ["BEGINNER", "INTERMEDIATE", "ADVANCE"], "atp.players.trainers.TrainerLevel", []}
  end

  defp schema() do
    File.read!("#{@schemas_path}/player_registered.avsc")
  end

  defp schema2() do
    File.read!("#{@schemas_path}/player_registered_trainer_as_ref.avsc")
  end

  defp schema3() do
    File.read!("#{@schemas_path}/player_registered_two_levels_nested_records.avsc")
  end

  defp schema4() do
    File.read!("#{@schemas_path}/trainer_with_inline_enum.avsc")
  end

  defp schema5() do
    File.read!("#{@schemas_path}/trainer_with_enum_as_ref.avsc")
  end

  defp schema6() do
    File.read!("#{@schemas_path}/trainer_with_same_enum_inline_and_as_ref.avsc")
  end
end
