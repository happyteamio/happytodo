defmodule HappyTodo.ParserTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule MyPlug do
    use Plug.Builder

    plug Plug.Parsers, parsers: [:urlencoded]
    plug HappyTodo.Parser
    plug :passthrough

    defp passthrough(conn, _) do
      Plug.Conn.send_resp(conn, 200, "Passthrough")
    end
  end

  test "raises for unfetched body" do
    conn = conn(:post, "/") |> Map.put(:body_params, %Plug.Conn.Unfetched{aspect: :body_params})

    assert_raise RuntimeError, "Unfetched", fn -> 
      HappyTodo.Parser.call(conn, [])
    end
  end

  test "parses request" do
    expected = %HappyTodo.Slack.Request{token: "MY_TOKEN", team_id: "Team123", command: "list", text: "please do"}
    encoded = Plug.Conn.Query.encode(expected |> Map.from_struct |> Map.update!(:command, &("/" <> &1)))

    conn = conn(:post, "/", encoded)
      |> set_content_type()
      |> call()
    
    assert conn.assigns[:request] == expected
    refute conn.halted
  end

  test "returns 404 for incomplete request" do
    encoded = Plug.Conn.Query.encode(%{token: "MY_TOKEN", team_id: "Team123"})
    conn = call(conn(:post, encoded))

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.halted
  end

  defp call(conn), do: MyPlug.call(conn, [])

  defp set_content_type(conn), do: put_req_header(conn, "content-type", "application/x-www-form-urlencoded")
end
