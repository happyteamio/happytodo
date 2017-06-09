defmodule HappyTodo.Repo.Migrations.AddTimestampsToItemTable do
  use Ecto.Migration

  def change do
    alter table(:item) do
      timestamps default: "2017-01-01 00:00:01"
    end
  end
end
