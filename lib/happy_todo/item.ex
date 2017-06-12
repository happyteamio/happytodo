defmodule HappyTodo.Item do
  import Ecto.Query
  use Ecto.Schema

  schema "item" do
    field :value, :string
    belongs_to :team, HappyTodo.Team
    timestamps [updated_at: false]
  end

  def by_team(team) do
    Ecto.assoc(team, :items)
  end

  def containing_value(query, value) do
    pattern = "%#{value}%"
    from i in query, where: ilike(i.value, ^pattern)
  end

  def with_value(query, value) do
    from i in query, where: ilike(i.value, ^value)
  end
end

