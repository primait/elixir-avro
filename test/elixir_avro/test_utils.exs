defmodule ElixirAvro.TestUtils do
  use ExUnit.Case

  alias ElixirAvro.AvroType.CustomProp
  alias ElixirAvro.AvroType.Enum
  alias ElixirAvro.AvroType.Primitive
  alias ElixirAvro.AvroType.Record
  alias ElixirAvro.AvroType.RecordField

  @expectations_folder "template/expectations"

  def birth_info_erl do
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

  def birth_info_ex do
    %Record{
      name: "BirthInfo",
      fullname: "atp.players.info.BirthInfo",
      namespace: "atp.players.info",
      doc: "Info about a player's birth.",
      fields: [
        %RecordField{
          name: "birthday",
          type: %Primitive{
            name: "int",
            custom_props: [%CustomProp{name: "logicalType", value: "date"}]
          },
          doc: "",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "father",
          type: "atp.players.info.Person",
          doc: "Father's info.",
          default: :undefined,
          order: :ascending,
          aliases: []
        }
      ],
      aliases: [],
      custom_props: []
    }
  end

  def birth_info_module_content do
    File.read!(Path.join(__DIR__, "#{@expectations_folder}/birth_info"))
  end

  def person_erl do
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

  def person_ex do
    %Record{
      name: "Person",
      fullname: "atp.players.info.Person",
      namespace: "",
      doc: "",
      fields: [
        %RecordField{
          name: "fullname",
          type: %Primitive{name: "string", custom_props: []},
          doc: "",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "age",
          type: %Primitive{name: "int", custom_props: []},
          doc: "",
          default: :undefined,
          order: :ascending,
          aliases: []
        }
      ],
      aliases: [],
      custom_props: []
    }
  end

  def person_module_content do
    File.read!(Path.join(__DIR__, "#{@expectations_folder}/person"))
  end

  def trainer_nested_erl do
    # Note: here we don't have an explicit namespace since it is inherited by the parent type
    {:avro_record_type, "Trainer", "atp.players", "A player trainer.", [],
     [
       {:avro_record_field, "fullname", "Full name of the trainer.",
        {:avro_primitive_type, "string", []}, :undefined, :ascending, []}
     ], "atp.players.Trainer", []}
  end

  def trainer_ref_erl do
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

  def trainer_ex do
    %Record{
      name: "Trainer",
      fullname: "atp.players.Trainer",
      namespace: "atp.players",
      doc: "A player trainer.",
      fields: [
        %RecordField{
          name: "fullname",
          type: %Primitive{name: "string", custom_props: []},
          doc: "Full name of the trainer.",
          default: :undefined,
          order: :ascending,
          aliases: []
        }
      ],
      aliases: [],
      custom_props: []
    }
  end

  def trainer_module_content do
    File.read!(Path.join(__DIR__, "#{@expectations_folder}/trainer"))
  end

  def player_registered_erl do
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

  def player_registered_ex do
    %Record{
      name: "PlayerRegistered",
      fullname: "atp.players.PlayerRegistered",
      namespace: "atp.players",
      doc: "A new player is registered in the atp ranking system.",
      fields: [
        %RecordField{
          name: "player_id",
          type: %Primitive{
            name: "string",
            custom_props: [%CustomProp{name: "logicalType", value: "uuid"}]
          },
          doc: "The unique identifier of the registered player (UUID).",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "full_name",
          type: %Primitive{name: "string", custom_props: []},
          doc: "The full name of the registered player.",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "rank",
          type: %Primitive{name: "int", custom_props: []},
          doc: "The current ranking of the registered player, start counting from 1.",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "registration_date",
          type: %Primitive{
            name: "int",
            custom_props: [%CustomProp{name: "logicalType", value: "date"}]
          },
          doc:
            "The date when the player was registered (number of UTC days from the unix epoch).",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "sponsor_name",
          type: %ElixirAvro.AvroType.Union{
            values: %{
              0 => %Primitive{name: "null", custom_props: []},
              1 => %Primitive{name: "string", custom_props: []}
            }
          },
          doc: "The name of the current sponsor (optional).",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "trainer",
          type: "atp.players.Trainer",
          doc: "Current trainer.",
          default: :undefined,
          order: :ascending,
          aliases: []
        }
      ],
      aliases: [],
      custom_props: []
    }
  end

  def player_registered_module_content do
    File.read!(Path.join(__DIR__, "#{@expectations_folder}/player_registered"))
  end

  def player_registered2_erl do
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

  def player_registered2_ex do
    %Record{
      name: "PlayerRegisteredTwoLevelsNestingRecords",
      fullname: "atp.players.PlayerRegisteredTwoLevelsNestingRecords",
      namespace: "atp.players",
      doc: "A new player is registered in the atp ranking system.",
      fields: [
        %RecordField{
          name: "player_id",
          type: %Primitive{
            name: "string",
            custom_props: [%CustomProp{name: "logicalType", value: "uuid"}]
          },
          doc: "The unique identifier of the registered player (UUID).",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "full_name",
          type: %Primitive{name: "string", custom_props: []},
          doc: "The full name of the registered player.",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "rank",
          type: %Primitive{name: "int", custom_props: []},
          doc: "The current ranking of the registered player, start counting from 1.",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "registration_date",
          type: %Primitive{
            name: "int",
            custom_props: [%CustomProp{name: "logicalType", value: "date"}]
          },
          doc:
            "The date when the player was registered (number of UTC days from the unix epoch).",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "sponsor_name",
          type: %ElixirAvro.AvroType.Union{
            values: %{
              0 => %Primitive{name: "null", custom_props: []},
              1 => %Primitive{name: "string", custom_props: []}
            }
          },
          doc: "The name of the current sponsor (optional).",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "trainer",
          type: "atp.players.Trainer",
          doc: "Current trainer.",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "birth_info",
          type: "atp.players.info.BirthInfo",
          doc: "",
          default: :undefined,
          order: :ascending,
          aliases: []
        }
      ],
      aliases: [],
      custom_props: []
    }
  end

  def player_registered2_module_content do
    File.read!(
      Path.join(__DIR__, "#{@expectations_folder}/player_registered_two_levels_nested_records")
    )
  end

  # Note: where is the enum?
  def trainer_with_enum_erl do
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

  def trainer_with_enum_ex do
    %Record{
      name: "Trainer",
      fullname: "atp.players.Trainer",
      namespace: "atp.players",
      doc: "A player trainer.",
      fields: [
        %RecordField{
          name: "fullname",
          type: %Primitive{name: "string", custom_props: []},
          doc: "Full name of the trainer.",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "level",
          type: "atp.players.trainers.TrainerLevel",
          doc: "",
          default: :undefined,
          order: :ascending,
          aliases: []
        }
      ],
      aliases: [],
      custom_props: []
    }
  end

  def trainer_with_enum_module_content do
    File.read!(Path.join(__DIR__, "#{@expectations_folder}/trainer_with_enum"))
  end

  def trainer_with_same_enum_inline_and_as_ref_erl do
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

  def trainer_with_same_enum_inline_and_as_ref_ex do
    %Record{
      name: "Trainer",
      fullname: "atp.players.Trainer",
      namespace: "atp.players",
      doc: "A player trainer.",
      fields: [
        %RecordField{
          name: "fullname",
          type: %Primitive{name: "string", custom_props: []},
          doc: "Full name of the trainer.",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "atp_level",
          type: "atp.players.trainers.TrainerLevel",
          doc: "Trainer certified level by ATP.",
          default: :undefined,
          order: :ascending,
          aliases: []
        },
        %RecordField{
          name: "fit_level",
          type: "atp.players.trainers.TrainerLevel",
          doc: "Trainer certified level by FIT.",
          default: :undefined,
          order: :ascending,
          aliases: []
        }
      ],
      aliases: [],
      custom_props: []
    }
  end

  def trainer_with_same_enum_inline_and_as_ref_module_content do
    File.read!(
      Path.join(__DIR__, "#{@expectations_folder}/trainer_with_same_enum_inline_and_as_ref")
    )
  end

  def trainer_level_erl do
    {:avro_enum_type, "TrainerLevel", "atp.players.trainers", [], "Trainer certified level.",
     ["BEGINNER", "INTERMEDIATE", "ADVANCE"], "atp.players.trainers.TrainerLevel", []}
  end

  def trainer_level_ex do
    %Enum{
      name: "TrainerLevel",
      fullname: "atp.players.trainers.TrainerLevel",
      namespace: "atp.players.trainers",
      doc: "Trainer certified level.",
      symbols: ["BEGINNER", "INTERMEDIATE", "ADVANCE"],
      aliases: [],
      custom_props: []
    }
  end

  def trainer_level_module_content do
    File.read!(Path.join(__DIR__, "#{@expectations_folder}/trainer_level"))
  end
end
