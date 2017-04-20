defmodule HappyReview.TeamValidatorTest do
  alias HappyReview.TeamValidator
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule MyPlug do
    use Plug.Builder

    plug Plug.Parsers, parsers: [:urlencoded]
    plug TeamValidator
    plug :passthrough

    defp passthrough(conn, _) do
      Plug.Conn.send_resp(conn, 200, "Passthrough")
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(HappyReview.Repo)
  end

  test "raises for unfetched body" do
    conn = conn(:post, "/") |> Map.put(:body_params, %Plug.Conn.Unfetched{aspect: :body_params})

    assert_raise RuntimeError, "Unfetched", fn -> 
      TeamValidator.call(conn, [])
    end
  end

  test "returns 404 for no team parameter" do
    conn = call(conn(:post, "/"))

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.halted
  end

  test "returns 404 for nonexistent team" do
    conn = conn(:post, "/", "team_id=T0BAD")
      |> set_content_type()
      |> call()

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.halted
  end

  test "existing team" do
    team_id = "TTESTTEAM"
    insert_team(team_id)
    conn = conn(:post, "/", "team_id=#{team_id}")
      |> set_content_type()
      |> call()

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Passthrough"
    refute conn.halted
  end

  defp call(conn), do: MyPlug.call(conn, [])

  defp insert_team(team_id) do
    HappyReview.Repo.insert!(%HappyReview.Team{team_id: team_id, name: "test"})
  end

  defp set_content_type(conn), do: put_req_header(conn, "content-type", "application/x-www-form-urlencoded")
end
