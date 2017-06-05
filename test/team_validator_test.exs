defmodule HappyTodo.TeamValidatorTest do
  alias HappyTodo.TeamValidator
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule MyPlug do
    use Plug.Builder

    plug TeamValidator
    plug :passthrough

    defp passthrough(conn, _) do
      Plug.Conn.send_resp(conn, 200, "Passthrough")
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(HappyTodo.Repo)
  end

  test "raises for missing request struct" do
    conn = conn(:post, "/")

    assert_raise RuntimeError, "Invalid request", fn -> 
      TeamValidator.call(conn, [])
    end
  end

  test "returns 404 for nonexistent team" do
    conn = conn(:post, "/") 
      |> assign(:request, %HappyTodo.Slack.Request{team_id: "T0BAD"})
      |> call()

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.halted
  end

  test "existing team" do
    team_id = "TTESTTEAM"
    insert_team(team_id)
    conn = conn(:post, "/")
      |> assign(:request, %HappyTodo.Slack.Request{team_id: team_id})
      |> call()

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Passthrough"
    refute conn.halted
  end

  defp call(conn), do: MyPlug.call(conn, [])

  defp insert_team(team_id) do
    HappyTodo.Repo.insert!(%HappyTodo.Team{team_id: team_id, name: "test"})
  end
end
