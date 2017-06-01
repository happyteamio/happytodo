defmodule HappyTodo.Repo.Migrations.CreateTeam do
  use Ecto.Migration

  def change do
    create table(:team) do
      add :team_id, :string
      add :name, :string
    end
  end
end
