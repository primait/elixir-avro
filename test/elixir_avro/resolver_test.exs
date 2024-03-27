defmodule ElixirAvro.Schema.ResolverTest do
  use ExUnit.Case

  alias ElixirAvro.Schema.Resolver
  alias ElixirAvro.TestUtils

  @schemas_path "test/elixir_avro/avro_schemas"

  describe "inline types" do
    test "record" do
      expected = %{
        "atp.players.PlayerRegistered" => TestUtils.player_registered_erl(),
        "atp.players.Trainer" => TestUtils.trainer_nested_erl()
      }

      types = resolve_types(schema())

      assert expected == types
    end

    test "enum" do
      expected = %{
        "atp.players.Trainer" => TestUtils.trainer_with_enum_erl(),
        "atp.players.trainers.TrainerLevel" => TestUtils.trainer_level_erl()
      }

      types = resolve_types(schema4())

      assert expected == types
    end
  end

  describe "cross references" do
    test "record" do
      expected = %{
        "atp.players.PlayerRegistered" => TestUtils.player_registered_erl(),
        "atp.players.Trainer" => TestUtils.trainer_ref_erl()
      }

      types = resolve_types([schema2(), File.read!("#{@schemas_path}/trainer.avsc")])

      assert expected == types
    end

    test "enum" do
      expected = %{
        "atp.players.Trainer" => TestUtils.trainer_with_enum_erl(),
        "atp.players.trainers.TrainerLevel" => TestUtils.trainer_level_erl()
      }

      types = resolve_types([schema5(), File.read!("#{@schemas_path}/trainer_level.avsc")])

      assert expected == types
    end

    test "cross reference to the current schema" do
      expected = %{
        "atp.players.Trainer" => TestUtils.trainer_with_same_enum_inline_and_as_ref_erl(),
        "atp.players.trainers.TrainerLevel" => TestUtils.trainer_level_erl()
      }

      types = resolve_types(schema6())

      assert expected == types
    end
  end

  describe "mixed inline and cross" do
    test "two levels of nested records" do
      expected = %{
        "atp.players.PlayerRegisteredTwoLevelsNestingRecords" =>
          TestUtils.player_registered2_erl(),
        "atp.players.Trainer" => TestUtils.trainer_nested_erl(),
        "atp.players.info.BirthInfo" => TestUtils.birth_info_erl(),
        "atp.players.info.Person" => TestUtils.person_erl()
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

  defp schema do
    File.read!("#{@schemas_path}/player_registered.avsc")
  end

  defp schema2 do
    File.read!("#{@schemas_path}/player_registered_trainer_as_ref.avsc")
  end

  defp schema3 do
    File.read!("#{@schemas_path}/player_registered_two_levels_nested_records.avsc")
  end

  defp schema4 do
    File.read!("#{@schemas_path}/trainer_with_inline_enum.avsc")
  end

  defp schema5 do
    File.read!("#{@schemas_path}/trainer_with_enum_as_ref.avsc")
  end

  defp schema6 do
    File.read!("#{@schemas_path}/trainer_with_same_enum_inline_and_as_ref.avsc")
  end
end
