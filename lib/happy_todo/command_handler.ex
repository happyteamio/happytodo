defmodule HappyTodo.CommandHandler do
  import Plug.Conn

  @behaviour Plug

  def init([]), do: []

  def call(conn, []) do
    handle(conn.body_params["command"], conn)
  end

  def handle("request", conn) do

  end
end
