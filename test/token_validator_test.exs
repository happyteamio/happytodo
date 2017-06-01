defmodule HappyTodo.TokenValidatorTest do
  alias HappyTodo.TokenValidator
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule MyPlug do
    use Plug.Builder

    @token "gIkuvaNzQIHg97ATvDxqgjtO"

    plug Plug.Parsers, parsers: [:urlencoded]
    plug TokenValidator, token: @token
    plug :passthrough

    defp passthrough(conn, _) do
      Plug.Conn.send_resp(conn, 200, "Passthrough")
    end

    def token, do: @token
  end

  defp call(conn), do: MyPlug.call(conn, [])

  test "raises for unfetched body" do
    conn = conn(:post, "/") |> Map.put(:body_params, %Plug.Conn.Unfetched{aspect: :body_params})

    assert_raise RuntimeError, "Unfetched", fn -> 
      TokenValidator.call(conn, "")
    end
  end

  test "returns 404 for no token" do
    conn = call(conn(:post, "/"))

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.halted
  end

  test "returns 404 for invalid token" do
    conn = conn(:post, "/", "token=th15t0k3n15wr0ng")
      |> set_content_type()
      |> call()

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.halted
  end

  test "valid token" do
    conn = conn(:post, "/", "token=#{MyPlug.token()}")
      |> set_content_type()
      |> call()

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Passthrough"
    refute conn.halted
  end

  defp set_content_type(conn), do: put_req_header(conn, "content-type", "application/x-www-form-urlencoded")
end
