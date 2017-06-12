defmodule HappyTodo.RouterTest do
  alias HappyTodo.Router
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule MyPlug do
    use Plug.Builder

    plug Router
    plug :passthrough

    defp passthrough(conn, _) do
      Plug.Conn.send_resp(conn, 200, "Passthrough")
    end
  end

  test "raises for missing request struct" do
    conn = conn(:post, "/")

    assert_raise RuntimeError, "Invalid request", fn ->
      Router.call(conn, [])
    end
  end

  test "returns 404 for unknown command" do
    conn = conn(:post, "/")
      |> assign(:request, %HappyTodo.Slack.Request{command: "what"})
      |> call()

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.halted
  end

  defp call(conn), do: MyPlug.call(conn, [])
end
