defmodule Mix.Tasks.Compile.ElixirAvroCodegen do
  @moduledoc """
  Mix compiler to allow mix to compile Avro source files into Elixir modules.

  Looks for `elixir_avro_codegen` key in your mix project config

      def project do
        [
          # ...
          elixir_avro_codegen: [
            schema_path: "avro",
            target_path: "avro",
            prefix: "MyApp.Avro",
            verbose: true
          ],
          compilers: Mix.compilers() ++ [:elixir_avro_codegen],
          # ...
        ]
      end

  Required options are:
  *  __schema_path__: The path to the directory containing the Avro schema files.
  * __target_path__:  The path to the directory where the generated Elixir code will be saved.
  * __prefix__:       The prefix to be used for the generated Elixir modules.

  Optional options are:
  * __verbose__: Enable verbose output. Defaults to `false`.
  """

  use Mix.Task.Compiler

  # works with umbrella apps
  @recursive true

  def run(_) do
    config = Mix.Project.config()

    codegen_config = get_or_raise(config, :elixir_avro_codegen)

    args = %{
      target_path: get_or_raise(codegen_config, :target_path),
      schemas_path: get_or_raise(codegen_config, :schema_path),
      prefix: get_or_raise(codegen_config, :prefix),
      verbose: Keyword.get(codegen_config, :verbose, false)
    }

    ElixirAvro.Codegen.run(args)
  end

  defp get_or_raise(config, key) do
    case Keyword.get(config, key) do
      nil -> raise usage(key)
      value -> value
    end
  end

  defp usage(key) do
    """
    missing #{key} in config. Please add it to your mix.exs file.

    Example:
    def project do
      [
        ...
        elixir_avro_codegen: [
          schema_path: "avro",  # required
          target_path: "avro",  # required
          prefix: "MyApp.Avro", # required
          verbose: true         # optional
        ],
        compilers: Mix.compilers() ++ [:elixir_avro_codegen],
        ...
      ]
    end
    """
  end
end
