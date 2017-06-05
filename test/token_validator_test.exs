defmodule HappyTodo.TokenValidatorTest do
  alias HappyTodo.TokenValidator
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule MyPlug do
    use Plug.Builder

    @token "gIkuvaNzQIHg97ATvDxqgjtO"

    plug TokenValidator, token: @token
    plug :passthrough

    defp passthrough(conn, _) do
      Plug.Conn.send_resp(conn, 200, "Passthrough")
    end

    def token, do: @token
  end

  defp call(conn), do: MyPlug.call(conn, [])

  test "raises for missing request struct" do
    conn = conn(:post, "/") 
    assert_raise RuntimeError, "Invalid request", fn -> 
      TokenValidator.call(conn, "")
    end
  end

  test "returns 404 for invalid token" do
    conn = conn(:post, "/") 
      |> assign(:request, %HappyTodo.Slack.Request{token: "faketoken"})
      |> call()

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.halted
  end

  test "valid token" do
    conn = conn(:post, "/") 
      |> assign(:request, %HappyTodo.Slack.Request{token: MyPlug.token()})
      |> call()

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Passthrough"
    refute conn.halted
  end
end
