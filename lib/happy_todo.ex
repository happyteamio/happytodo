defmodule HappyTodo do
  import Plug.Conn
  require IEx
  use Plug.Builder

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug HappyTodo.Parser
  plug HappyTodo.TokenValidator
  plug HappyTodo.TeamValidator
  plug :process

  def request(conn, text) do
    IO.inspect text
    conn |> reply("Hasta la vista, baby")
  end

  def reply(conn, response) do
    response_struct = HappyTodo.Slack.Response.in_channel(response)
    json = Poison.encode!(response_struct)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, json)
  end

  def process(conn, _opts) do
    case conn.body_params["command"] do
      # %{"request"} -> request(conn, conn.body_params["text"])
      # %{"pick"} -> pick(conn, conn.body_params["text"])
      # %{"list"} -> list(conn, conn.body_params["text"])
      %{} -> reply(conn, "Unknown command")
    end
  end
end
