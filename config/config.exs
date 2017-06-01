# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :happy_todo, token: "YOUR_TOKEN_HERE"

config :happy_todo, ecto_repos: [HappyTodo.Repo]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
