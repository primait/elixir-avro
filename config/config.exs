import Config

if Mix.env() == :test do
  config :logger, level: :info
end

config :elixir_avro, :custom_logical_types, %{}

import_config "#{config_env()}.exs"
