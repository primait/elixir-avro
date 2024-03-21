defmodule ElixirAvro.Generator.Names do
  @moduledoc """
  Utility for elixir module names.
  """
  @spec camelize(String.t()) :: String.t()
  def camelize(fullname) do
    fullname
    |> String.split(".")
    |> Enum.map_join(".", &Macro.camelize/1)
  end

  @spec module_name!(String.t(), String.t()) :: String.t() | no_return
  def module_name!("", _prefix) do
    raise ArgumentError, "empty name for module"
  end

  def module_name!(name, prefix) when is_binary(name) do
    case prefix do
      _ when is_nil(prefix) or prefix == "" -> :"#{Names.camelize(name)}"
      _ -> :"#{Names.camelize(prefix)}.#{Names.camelize(name)}"
    end
  end

  def module_name!(name, _prefix) do
    raise ArgumentError, "invalid name for module: #{inspect(name)}"
  end
end
