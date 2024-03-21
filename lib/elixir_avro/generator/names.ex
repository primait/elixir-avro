defmodule ElixirAvro.Generator.Names do
  @moduledoc """
  Utility for elixir module names.
  """
  def camelize(fullname) do
    fullname
    |> String.split(".")
    |> Enum.map_join(".", &Macro.camelize/1)
  end
end
