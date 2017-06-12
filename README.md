# HappyTodo

Slack TODO app built on [plugs](https://github.com/elixir-lang/plug/).
Supports the following commands:
* `/add text` - adds a new todo item
* `/list` - lists the items
* `/pick text` - removes the item containing `text` from the list 

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `happy_todo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:happy_todo, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/happy_todo](https://hexdocs.pm/happy_todo).

