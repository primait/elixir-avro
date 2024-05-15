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

  @spec module_name!(String.t(), String.t() | atom()) :: atom() | no_return()
  def module_name!("", _) do
    raise ArgumentError, "empty name for module"
  end

  def module_name!(name, prefix) when is_binary(name) do
    name = camelize(name)

    cond do
      is_nil(prefix) or prefix == "" -> to_atom(camelize(name))
      is_binary(prefix) -> String.to_atom("#{camelize(prefix)}.#{camelize(name)}")
      is_atom(prefix) -> String.to_atom("#{prefix |> Atom.to_string() |> camelize()}.#{camelize(name)}")
      true -> raise ArgumentError, "invalid prefix for module: #{inspect(prefix)}"
    end
  end

  def module_name!(name, _) do
    raise ArgumentError, "invalid name for module: #{inspect(name)}"
  end

  @spec to_atom(String.t() | atom()) :: atom()
  def to_atom(arg) when is_atom(arg), do: arg

  def to_atom(arg) when is_binary(arg) do
    String.to_existing_atom(arg)
  rescue
    ArgumentError ->
      String.to_atom(arg)
  end
end
