defmodule HappyTodo.Slack.Request do
  @moduledoc """
  Slack request structure
  """

  defstruct [:token, :team_id, :command, :text, :team]
end
