defmodule HappyTodo.Slack.Request do
  @moduledoc """
  Slack request structure
  """

  defstruct [:token, :team_id, :team, :user_name, :command, :text]
end
