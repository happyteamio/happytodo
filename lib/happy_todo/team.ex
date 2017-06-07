defmodule HappyTodo.Team do
  use Ecto.Schema

  schema "team" do
    field :team_id, :string
    field :name, :string
    has_many :items, HappyTodo.Item
  end
end
