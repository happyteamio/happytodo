defmodule HappyReview do
  import Plug.Conn
  require IEx
  use Plug.Builder

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug :quack

  #def init(options), do: options

  def quack(conn, _opts) do
    IEx.pry
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello")
  end
end
