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
    result = add_item(team, "new item")
    new_item = get_single_item()

    assert result == {:public, "new item added"}
    assert %Item{value: "new item", team: ^team} = new_item
  end

  test "trims item text", %{team: team} = _context do
    add_item(team, "    new item\n  ")
    new_item = get_single_item()

    assert %Item{value: "new item"} = new_item
  end

  test "prevents adding empty item", %{team: team} = _context do
    result = add_item(team, "   \n  ")
    new_item = get_single_item()

    assert result == {:private, "cannot add empty item"}
    assert new_item == nil 
  end

  test "prevents adding an existing item", %{team: team} = _context do
    add_item(team, "new item")

    result = add_item(team, "new item")
    items_count = Repo.aggregate(Item, :count, :id)

    assert result == {:private, "item already exists"}
    assert items_count == 1
  end

  test "lists when no items", %{team: team} = _context do
    insert_another_team_data()

    result = list(%Request{team: team})

    assert result == {:private, "no items"}
  end


  test "lists team's items", %{team: team} = _context do
    insert_another_team_data()
    add_item(team, "new item1")
    add_item(team, "new item2")

    result = list(%Request{team: team})

    assert result == {:private, "1. new item1\n2. new item2"}
  end

  test "picks an item", %{team: team} = _context do
    insert_another_team_data()
    add_item(team, "new item")

    result = pick_item(team, "ashenone", "new item")
    items_count = team |> items_for_team |> length

    assert result == {:public, ~s(@ashenone picked "new item")}
    assert items_count == 0
  end

  test "picks an item by partial name", %{team: team} = _context do
    items = %{0 => "this is item one", 1 => "this is another item"}
    Map.values(items) |> Enum.map(&add_item(team, &1))

    result = pick_item(team, "ashenone", "another")
    remaining_items = team |> items_for_team
    expected_value = items[0]

    assert result == {:public, ~s(@ashenone picked "#{items[1]}")}
    assert [%Item{value: ^expected_value}] = remaining_items
  end

  test "pick returns error for empty item", %{team: team} = _context do
    add_item(team, "new item")
    result = pick_item(team, "yhorm", "")

    assert result == {:private, "cannot pick empty item"}
    assert length(items_for_team(team)) == 1
  end

  test "pick returns error for non-existing item", %{team: team} = _context do
    insert_another_team_data()
    add_item(team, "new item")
    result = pick_item(team, "yhorm", "test")

    assert result == {:private, ~s(item "test" does not exist)}
    assert length(items_for_team(team)) == 1
  end

  test "pick returns error for ambiguous results", %{team: team} = _context do
    insert_another_team_data()
    add_item(team, "new item")
    add_item(team, "another item")
    result = pick_item(team, "yhorm", "item")

    assert result == {:private, ~s(ambiguous results for "item")}
    assert length(items_for_team(team)) == 2
  end

  test "pick trims long item summary", %{team: team} = _context do
    insert_another_team_data()
    long_text = Enum.join(0..9) |> List.duplicate(20) |> Enum.join()
    add_item(team, long_text)

    result = pick_item(team, "ashenone", "1234")
    substring = long_text |> String.slice(0..99)

    assert result == {:public, ~s/@ashenone picked "#{substring}(...)"/}
  end

  defp get_single_item do
    Item |> preload(:team) |> Repo.one
  end

  defp add_item(team, value) do
    add(%Request{team: team, text: value})
  end

  defp pick_item(team, user, value) do
    pick(%Request{team: team, user_name: user, text: value})
  end

  defp items_for_team(team) do
    Repo.all(Item.by_team(team))
  end

  defp insert_another_team_data do
    team = Repo.insert!(%HappyTodo.Team{team_id: "ANOTHERTEAM1", name: "another team"})
    add_item(team, "new item")
    add_item(team, "new item2")
  end
end
