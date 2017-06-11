defmodule HappyTodo.CommandHandler do
  alias HappyTodo.{Item, Repo}
  import Ecto
  import Ecto.Query

  def add(request) do
    value = String.trim(request.text || "")
    with {:ok, _value} <- add_validate_item(request.team, value),
         new_item = build_assoc(request.team, :items, value: value),
         :ok <- add_insert_item(new_item) do
      {:public, "new item added"}
    else
      {:error, message} -> {:private, message}
    end
  end

  defp add_validate_item(_team, ""), do: {:error, "cannot add empty item"}
  defp add_validate_item(team, value) do
    item = Item.by_team(team) |> Item.with_value(value)
    if Repo.exists(item, :id) do
      {:error, "item already exists"}
    else
      {:ok, value}
    end
  end

  defp add_insert_item(item) do
    case Repo.insert(item) do
      {:ok, _item} -> :ok
      {:error, _changeset} -> {:error, "db error"}
    end
  end

  def pick(_, _), do: nil

  def list(request) do
    items = Repo.all from i in Item.by_team(request.team),
                     select: i.value,
                     order_by: i.inserted_at

    response = items |> Enum.with_index(1) |> Enum.map_join("\n", fn({item, index}) -> "#{index}. #{item}" end)
    {:private, response}
  end
end
