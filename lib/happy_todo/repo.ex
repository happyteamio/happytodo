defmodule HappyTodo.Repo do
  use Ecto.Repo, otp_app: :happy_todo

  def exists(query, column) do
    aggregate(query, :count, column) > 0
  end
end
