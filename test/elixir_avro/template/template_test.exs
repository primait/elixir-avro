defmodule ElixirAvro.TemplateTest do
  use ExUnit.Case

  alias ElixirAvro.Template
  alias ElixirAvro.TestUtils

  @prefix "Prefix"

  test "birth_info can be rendered" do
    ex_types = [TestUtils.birth_info_ex()]
    expected = %{"#{@prefix}.Atp.Players.Info.BirthInfo": TestUtils.birth_info_module_content()}
    assert Template.eval_all!(ex_types, @prefix) == expected
  end

  test "person can be rendered" do
    ex_types = [TestUtils.person_ex()]
    expected = %{"#{@prefix}.Atp.Players.Info.Person": TestUtils.person_module_content()}
    assert Template.eval_all!(ex_types, @prefix) == expected
  end

  test "trainer can be rendered" do
    ex_types = [TestUtils.trainer_ex()]
    expected = %{"#{@prefix}.Atp.Players.Trainer": TestUtils.trainer_module_content()}
    assert Template.eval_all!(ex_types, @prefix) == expected
  end

  test "player_registered can be rendered" do
    ex_types = [TestUtils.player_registered_ex()]

    expected = %{
      "#{@prefix}.Atp.Players.PlayerRegistered": TestUtils.player_registered_module_content()
    }

    assert Template.eval_all!(ex_types, @prefix) == expected
  end

  test "player_registered2 can be rendered" do
    ex_types = [TestUtils.player_registered2_ex()]

    expected = %{
      "#{@prefix}.Atp.Players.PlayerRegisteredTwoLevelsNestingRecords":
        TestUtils.player_registered2_module_content()
    }

    assert Template.eval_all!(ex_types, @prefix) == expected
  end

  # Note: where is the enum?
  test "trainer_with_enum can be rendered" do
    ex_types = [TestUtils.trainer_with_enum_ex()]
    expected = %{"#{@prefix}.Atp.Players.Trainer": TestUtils.trainer_with_enum_module_content()}
    assert Template.eval_all!(ex_types, @prefix) == expected
  end

  test "trainer_with_same_enum_inline_and_as_ref can be rendered" do
    ex_types = [TestUtils.trainer_with_same_enum_inline_and_as_ref_ex()]

    expected = %{
      "#{@prefix}.Atp.Players.Trainer":
        TestUtils.trainer_with_same_enum_inline_and_as_ref_module_content()
    }

    assert Template.eval_all!(ex_types, @prefix) == expected
  end

  test "trainer_level can be rendered" do
    ex_types = [TestUtils.trainer_level_ex()]

    expected = %{
      "#{@prefix}.Atp.Players.Trainers.TrainerLevel": TestUtils.trainer_level_module_content()
    }

    assert Template.eval_all!(ex_types, @prefix) == expected
  end
end
