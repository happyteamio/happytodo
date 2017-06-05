defmodule HappyTodo.TokenValidator do
  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Keyword.get(opts, :token, Application.get_env(:happy_todo, :token))
  end

  def call(conn, token) do
    case conn.assigns[:request] do
      %HappyTodo.Slack.Request{token: ^token} -> conn
      nil -> raise "Invalid request"
      _ -> conn |> send_resp(404, "") |> halt()
    end
  end
end
