defmodule ElixirAvro.Schema.Record do
  @moduledoc nil

  # NOTE: would be cool to add a behaviour to return doc, name and specific_bindings

  @type t :: %__MODULE__{
          name: String.t(),
          fullname: String.t(),
          namespace: String.t(),
          doc: String.t(),
          fields: [field],
          template_path: String.t(),
          aliases: [],
          custom: []
        }

  @type field :: {
          atom,
          name :: String.t(),
          doc :: String.t(),
          type :: field_type,
          atom,
          atom,
          aliases: []
        }

  @type field_type :: {
          atom,
          primitive_type :: String.t(),
          logical :: []
        }

  @type field_meta :: %{
          doc: String.t(),
          name: String.t(),
          erlavro_type: String.t()
        }

  @template_path Path.join(__DIR__, "../generator/templates/record.ex.eex")

  defstruct [
    :name,
    :fullname,
    :namespace,
    :doc,
    :fields,
    template_path: @template_path,
    aliases: [],
    custom: []
  ]

  @spec get_specific_bindings(t()) :: [{:fields_meta, [field_meta]}]
  def get_specific_bindings(%__MODULE__{fields: fields}) do
    [fields_meta: Enum.map(fields, &field_meta/1)]
  end

  @spec field_meta(tuple) :: field_meta
  defp field_meta({:avro_record_field, name, doc, type, :undefined, :ascending, _aliases}) do
    %{
      doc: doc,
      name: name,
      erlavro_type: type
    }
  end
end
