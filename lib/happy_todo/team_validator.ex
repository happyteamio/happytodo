defmodule HappyTodo.TeamValidator do
  import Plug.Conn
  alias HappyTodo.{Repo, Team}

  @behaviour Plug

  def init([]), do: []

  def call(conn, []) do
    case conn.body_params do
      %{"team_id" => team_id} -> validate_team(conn, team_id)
      %Plug.Conn.Unfetched{} -> raise "Unfetched"
      %{} -> conn |> send_resp(404, "") |> halt()
    end
  end

  defp validate_team(conn, team_id) do
    team = fetch_team(team_id)
    conn |> process_team(team)
  end
  
  defp fetch_team(team_id), do: Team |> Repo.get_by(team_id: team_id)

  defp process_team(conn, nil) do
    conn |> send_resp(404, "") |> halt()
  end
  defp process_team(conn, _team), do: conn
end
