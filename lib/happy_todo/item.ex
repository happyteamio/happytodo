defmodule HappyTodo.Item do
  use Ecto.Schema

  schema "item" do
    field :value, :string
    belongs_to :team, HappyTodo.Team
    timestamps [updated_at: false]
  end
end

