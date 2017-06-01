defmodule HappyTodo.Slack.Response do
  @moduledoc """
  Slack response helpers
  """

  @derive [Poison.Encoder]
  defstruct [:text, :response_type]

  @doc """
  Sends the private (aka. `ephemeral` response) - neither the request nor the response will be visible
  """
  def private(text) do
    %__MODULE__{text: text, response_type: "ephemeral"}
  end

  @doc """
  Sends the public (aka. `in_channel` response) - both the request and the response will be visible
  """
  def public(text) do
    %__MODULE__{text: text, response_type: "in_channel"}
  end
end
