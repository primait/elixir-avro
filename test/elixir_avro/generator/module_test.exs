defmodule ElixirAvro.Generator.ModuleTest do
  use ExUnit.Case

  @expectations_folder "expectations"
  @schemas_folder "schemas"

  @modules_namespace "My.Fantastic.App"

  @trainer_schema """
  {
    "name": "Trainer",
    "namespace": "atp.players",
    "type": "record",
    "fields": [
        {
            "name": "fullname",
            "type": "string",
            "doc": "Full name of the trainer."
        }
    ],
    "doc": "A player trainer."
  }
  """

  @person_schema """
  {
    "name": "Person",
    "namespace": "atp.players.info",
    "type": "record",
    "fields": [
        {
            "name": "fullname",
            "type": "string"
        },
        {
            "name": "age",
            "type": "int"
        }
    ]
  }
  """

  alias ElixirAvro.Generator.Module, as: ModuleGenerator
  alias ElixirAvro.Schema.Resolver, as: SchemaResolver

  test "inline record" do
    expected = %{
      "#{@modules_namespace}.Atp.Players.PlayerRegistered" => player_registered_module_content(),
      "#{@modules_namespace}.Atp.Players.Trainer" => trainer_module_content()
    }

    modules = modules_from_schemas(schema())

    assert expected == modules
  end

  test "two levels of inline record" do
    expected = %{
      "#{@modules_namespace}.Atp.Players.PlayerRegisteredTwoLevelsNestingRecords" =>
        player_registered2_module_content(),
      "#{@modules_namespace}.Atp.Players.Trainer" => trainer_module_content(),
      "#{@modules_namespace}.Atp.Players.Info.BirthInfo" => birth_info_module_content(),
      "#{@modules_namespace}.Atp.Players.Info.Person" => person_module_content()
    }

    modules = modules_from_schemas(schema2())

    assert expected == modules
  end

  test "two levels of nested records with mixed cross reference and inline" do
    expected = %{
      "#{@modules_namespace}.Atp.Players.PlayerRegisteredTwoLevelsNestingRecords" =>
        player_registered2_module_content(),
      "#{@modules_namespace}.Atp.Players.Trainer" => trainer_module_content(),
      "#{@modules_namespace}.Atp.Players.Info.BirthInfo" => birth_info_module_content(),
      "#{@modules_namespace}.Atp.Players.Info.Person" => person_module_content()
    }

    modules = modules_from_schemas([schema3(), @person_schema, @trainer_schema])

    assert expected == modules
  end

  test "inline enum" do
    expected = %{
      "#{@modules_namespace}.Atp.Players.Trainer" => trainer_with_enum_module_content(),
      "#{@modules_namespace}.Atp.Players.Trainers.TrainerLevel" => trainer_level_module_content()
    }

    modules = modules_from_schemas(schema4())
    assert expected == modules
  end

  @spec modules_from_schemas(String.t() | [String.t()]) :: map()
  defp modules_from_schemas(schema) when is_binary(schema), do: modules_from_schemas([schema])

  defp modules_from_schemas(schemas) do
    schemas
    |> SchemaResolver.resolve_types()
    |> ModuleGenerator.modules_from_schemas(@modules_namespace)
  end

  defp player_registered_module_content() do
    File.read!(Path.join(__DIR__, "#{@expectations_folder}/player_registered"))
  end

  defp player_registered2_module_content() do
    File.read!(
      Path.join(__DIR__, "#{@expectations_folder}/player_registered_two_levels_nested_records")
    )
  end

  defp trainer_module_content() do
    File.read!(Path.join(__DIR__, "#{@expectations_folder}/trainer"))
  end

  defp trainer_with_enum_module_content() do
    File.read!(Path.join(__DIR__, "#{@expectations_folder}/trainer_with_enum"))
  end

  defp birth_info_module_content() do
    File.read!(Path.join(__DIR__, "#{@expectations_folder}/birth_info"))
  end

  defp person_module_content() do
    File.read!(Path.join(__DIR__, "#{@expectations_folder}/person"))
  end

  defp trainer_level_module_content() do
    File.read!(Path.join(__DIR__, "#{@expectations_folder}/trainer_level"))
  end

  defp schema() do
    File.read!(Path.join(__DIR__, "#{@schemas_folder}/player_registered.avsc"))
  end

  defp schema2() do
    File.read!(
      Path.join(__DIR__, "#{@schemas_folder}/player_registered_two_levels_nested_records.avsc")
    )
  end

  defp schema3() do
    File.read!(Path.join(__DIR__, "#{@schemas_folder}/player_registered_with_record_ref.avsc"))
  end

  defp schema4() do
    File.read!(Path.join(__DIR__, "#{@schemas_folder}/trainer_with_inline_enum.avsc"))
  end
end
