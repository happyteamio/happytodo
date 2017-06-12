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

  def pick(request) do
    with {:ok, value} <- pick_validate_item(String.trim(request.text || "")),
         {:ok, item} <- pick_fetch_item(request.team, value),
         :ok <- pick_remove_item(item) do
      formatted_item = if String.length(item.value) > 100 do
        "#{String.slice(item.value, 0..99)}(...)"
      else
        item.value
      end

      {:public, ~s(@#{request.user_name} picked "#{formatted_item}")}
    else
      {:error, message} -> {:private, message}
    end
  end

  defp pick_validate_item(""), do: {:error, "cannot pick empty item"}
  defp pick_validate_item(item), do: {:ok, item}

  defp pick_fetch_item(team, item_text) do
    items = Item.by_team(team) |> Item.containing_value(item_text) |> limit(2)
    case Repo.all(items) do
      [] -> {:error, ~s(item "#{item_text}" does not exist)}
      [item] -> {:ok, item}
      _ -> {:error, ~s(ambiguous results for "#{item_text}")}
    end
  end

  defp pick_remove_item(item) do
    case Repo.delete(item) do
      {:ok, _item} -> :ok
      {:error, _changeset} -> {:error, "db error"}
    end
  end

  def list(request) do
    items = Repo.all from i in Item.by_team(request.team),
                     select: i.value,
                     order_by: i.inserted_at

    response = case length(items) do
      0 -> "no items"
      _ -> items |> Enum.with_index(1) |> Enum.map_join("\n", fn({item, index}) -> "#{index}. #{item}" end)
    end

    {:private, response}
  end
end
