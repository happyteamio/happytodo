defmodule HappyTodo.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(HappyTodo.Repo, []),
      Plug.Adapters.Cowboy.child_spec(:http, HappyTodo, [], [port: 4001])
    ]

    opts = [strategy: :one_for_one, name: HappyTodo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
