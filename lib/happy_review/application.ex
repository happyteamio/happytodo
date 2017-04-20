defmodule HappyReview.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(HappyReview.Repo, []),
      Plug.Adapters.Cowboy.child_spec(:http, HappyReview, [], [port: 4001])
    ]

    opts = [strategy: :one_for_one, name: HappyReview.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
