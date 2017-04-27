defmodule HappyReview.TokenValidator do
  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Keyword.get(opts, :token, Application.get_env(:happy_review, :token))
  end

  def call(conn, token) do
    case conn.body_params do
      %{"token" => ^token} -> conn
      %Plug.Conn.Unfetched{} -> raise "Unfetched"
      %{} -> conn |> send_resp(404, "") |> halt()
    end
  end
end
