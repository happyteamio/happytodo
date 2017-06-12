defmodule HappyTodo.Router do
  import Plug.Conn
  import HappyTodo.CommandHandler

  @behaviour Plug

  def init([]), do: []

  def call(conn, _opts), do: handle(conn, conn.assigns[:request])

  defp handle(conn, %HappyTodo.Slack.Request{command: command} = slack_request) do
    case execute_command(command, slack_request) do
      {:ok, response} -> conn |> reply(response)
      :error -> conn |> send_resp(404, "") |> halt
    end
  end
  defp handle(_conn, _request) do
    raise "Invalid request"
  end
  
  defp execute_command(command, slack_request) do
    case command do
      "add" -> {:ok, add(slack_request)}
      "pick" -> {:ok, pick(slack_request)}
      "list" -> {:ok, list(slack_request)}
      _ -> :error
    end
  end

  defp reply(conn, response) do
    response_struct = to_slack_response(response)
    json = response_struct |> Poison.encode!
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, json)
  end

  defp to_slack_response({:public, response}), do: HappyTodo.Slack.Response.public(response)
  defp to_slack_response({:private, response}), do: HappyTodo.Slack.Response.private(response)
end
