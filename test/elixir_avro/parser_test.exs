defmodule ElixirAvro.Schema.ParserTest do
  use ExUnit.Case

  alias ElixirAvro.Schema.Parser
  alias ElixirAvro.TestUtils

  test "birth_info can be parsed" do
    erlavro_schema = TestUtils.birth_info_erl()
    expected = [TestUtils.birth_info_ex()]
    assert Parser.from_erl_types([erlavro_schema]) == expected
  end

  test "person can be parsed" do
    erlavro_schema = TestUtils.person_erl()
    expected = [TestUtils.person_ex()]
    assert Parser.from_erl_types([erlavro_schema]) == expected
  end

  test "trainer_nested can be parsed" do
    erlavro_schema = TestUtils.trainer_nested_erl()
    expected = [TestUtils.trainer_ex()]
    assert Parser.from_erl_types([erlavro_schema]) == expected
  end

  test "trainer_ref can be parsed" do
    erlavro_schema = TestUtils.trainer_ref_erl()
    expected = [TestUtils.trainer_ex()]
    assert Parser.from_erl_types([erlavro_schema]) == expected
  end

  test "player_registered can be parsed" do
    erlavro_schema = TestUtils.player_registered_erl()
    expected = [TestUtils.player_registered_ex()]
    assert Parser.from_erl_types([erlavro_schema]) == expected
  end

  test "player_registered2 can be parsed" do
    erlavro_schema = TestUtils.player_registered2_erl()
    expected = [TestUtils.player_registered2_ex()]
    assert Parser.from_erl_types([erlavro_schema]) == expected
  end

  # Note: where is the enum?
  test "trainer_with_enum can be parsed" do
    erlavro_schema = TestUtils.trainer_with_enum_erl()
    expected = [TestUtils.trainer_with_enum_ex()]
    assert Parser.from_erl_types([erlavro_schema]) == expected
  end

  test "trainer_with_same_enum_inline_and_as_ref can be parsed" do
    erlavro_schema = TestUtils.trainer_with_same_enum_inline_and_as_ref_erl()
    expected = [TestUtils.trainer_with_same_enum_inline_and_as_ref_ex()]
    assert Parser.from_erl_types([erlavro_schema]) == expected
  end

  test "trainer_level can be parsed" do
    erlavro_schema = TestUtils.trainer_level_erl()
    expected = [TestUtils.trainer_level_ex()]
    assert Parser.from_erl_types([erlavro_schema]) == expected
  end
end
