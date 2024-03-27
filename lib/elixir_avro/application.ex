defmodule ElixirAvro.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_, _) do
    children = []

    opts = [strategy: :one_for_one, name: ElixirAvro.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
