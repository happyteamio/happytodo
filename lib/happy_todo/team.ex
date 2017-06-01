defmodule HappyTodo.Team do
  use Ecto.Schema

  schema "team" do
    field :team_id, :string
    field :name, :string
  end
end
