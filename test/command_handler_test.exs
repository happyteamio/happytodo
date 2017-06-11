defmodule HappyTodo.CommandHandlerTest do
  import Ecto.Query
  import HappyTodo.CommandHandler
  alias HappyTodo.{Item, Repo, Slack.Request}
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    team = Repo.insert!(%HappyTodo.Team{team_id: "TEAM123", name: "test team"})

    [team: team]
  end

  test "adds a new item", %{team: team} = _context do
    request = %Request{team: team, text: "new item"}
    result = add(request)
    new_item = get_single_item()

    assert result == {:public, "new item added"}
    assert %Item{value: "new item", team: ^team} = new_item
  end

  test "trims item text", %{team: team} = _context do
    request = %Request{team: team, text: "    new item\n  "}
    add(request)
    new_item = get_single_item()

    assert %Item{value: "new item"} = new_item
  end

  test "prevents adding empty item", %{team: team} = _context do
    request = %Request{team: team, text: "   \n  "}
    result = add(request)
    new_item = get_single_item()

    assert result == {:private, "cannot add empty item"}
    assert new_item == nil 
  end

  test "prevents adding an existing item", %{team: team} = _context do
    add(%Request{team: team, text: "new item"})
    result = add(%Request{team: team, text: "new item"})
    items_count = Repo.aggregate(Item, :count, :id)

    assert result == {:private, "item already exists"}
    assert items_count == 1
  end

  defp get_single_item do
    Item |> preload(:team) |> Repo.one
  end
end
