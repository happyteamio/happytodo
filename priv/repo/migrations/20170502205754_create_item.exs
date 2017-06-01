defmodule HappyTodo.Repo.Migrations.CreateItem do
  use Ecto.Migration

  def change do
    create table(:item) do
      add :team_id, references(:team, [on_delete: :delete_all])
      add :value, :string
    end
  end
end
