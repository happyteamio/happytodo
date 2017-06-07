defmodule HappyTodo.Item do
  use Ecto.Schema

  schema "item" do
    field :value, :string
    belongs_to :team, HappyTodo.Team
  end
end

