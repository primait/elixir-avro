defmodule ElixirAvro.Template.Names do
  @moduledoc """
  Utility for elixir module names.
  """

  @spec camelize(String.t()) :: String.t()
  def camelize(fullname) when is_binary(fullname) do
    fullname
    |> String.split(".")
    |> Enum.map_join(".", &Macro.camelize/1)
  end

  @spec module_name!(String.t(), String.t()) :: String.t() | no_return()
  def module_name!("", _) do
    raise ArgumentError, "empty name for module"
  end

  def module_name!(name, prefix) when is_binary(name) do
    case prefix do
      _ when is_nil(prefix) or prefix == "" -> "#{camelize(name)}"
      _ when is_binary(prefix) -> "#{camelize(prefix)}.#{camelize(name)}"
      _ when is_atom(prefix) -> "#{prefix |> Atom.to_string() |> camelize()}.#{camelize(name)}"
      _ -> raise ArgumentError, "invalid prefix for module: #{inspect(prefix)}"
    end
  end

  def module_name!(name, _) do
    raise ArgumentError, "invalid name for module: #{inspect(name)}"
  end
end
