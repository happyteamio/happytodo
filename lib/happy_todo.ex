defmodule HappyTodo do
  use Plug.Builder

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug HappyTodo.Parser
  plug HappyTodo.TokenValidator
  plug HappyTodo.TeamValidator
  plug HappyTodo.Router
end
