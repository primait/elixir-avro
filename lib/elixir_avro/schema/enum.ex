defmodule ElixirAvro.Schema.Enum do
  @moduledoc nil

  @type t :: %__MODULE__{
          name: String.t(),
          fullname: String.t(),
          namespace: String.t(),
          doc: String.t(),
          symbols: [String.t()],
          template_path: String.t(),
          aliases: [],
          custom: []
        }

  @template_path Path.join(__DIR__, "../generator/templates/enum.ex.eex")

  defstruct [
    :name,
    :fullname,
    :namespace,
    :doc,
    :symbols,
    template_path: @template_path,
    aliases: [],
    custom: []
  ]

  @spec get_specific_bindings(t()) :: [tuple]
  def get_specific_bindings(%__MODULE__{symbols: symbols}) do
    [values: symbols]
  end
end
