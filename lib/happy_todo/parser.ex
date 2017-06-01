defmodule HappyTodo.Parser do
  import Plug.Conn
  @behaviour Plug

  def init([]), do: []

  def call(conn, _opts) do
    case conn.body_params do
      %{
        "token" => token,
        "team_id" => team_id,
        "command" => "/" <> command,
        "text" => text
      } => %HappyTodo.Slack.Request{token: token, team_id: team_id, command: command, text: text}
      %Plug.Conn.Unfetched{} -> raise "Unfetched"
      %{} -> conn |> send_resp(404, "") |> halt()
    end
  end
end
