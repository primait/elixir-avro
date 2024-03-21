defmodule ElixirAvro.ElixirEnum do
  @moduledoc """
  In the client module we expected a module attribute @values that contains a list of strings.

  This macro will be used by the generated code, when enums, to create convenient function to access the enum variants.
  """

  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote unquote: false do
      values =
        __MODULE__
        |> Module.get_attribute(:values, [])
        |> Enum.uniq()
        |> Enum.map(&{&1 |> String.downcase() |> String.to_atom(), &1})

      if Enum.empty?(values) do
        raise "@values attribute should be set and not empty"
      end

      Enum.map(values, fn {atom, string} ->
        defmacro unquote(:"#{atom}_")(),
          do: unquote(atom)

        def unquote(atom)(),
          do: unquote(atom)

        def to_avro_string(unquote(atom)),
          do: unquote(string)

        def from_avro_string(unquote(string)),
          do: unquote(atom)
      end)
    end
  end
end
