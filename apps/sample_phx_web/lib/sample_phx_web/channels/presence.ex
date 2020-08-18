defmodule SamplePhxWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](http://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :sample_phx_web,
    pubsub_server: SamplePhxWeb.PubSub

  alias SamplePhx.Accounts

  @doc """
  An optional callback that fetches the data for a batch of precences.
  The `entries` param is a map of user id to session metadata pairs. We could
  decorate the entries map with any data we want. Our only oblication is to carry
  over the original `:metas` information as it has the data necessary for
  tracking presence data over a client.
  """
  def fetch(_topic, entries) do
    # %{"123" => %{username: "jvalim"}, ...}
    users_map =
      entries
      |> Map.keys()
      |> Accounts.list_users_with_ids()
      |> Enum.into(%{}, fn user ->
        {to_string(user.id), %{username: user.username}}
      end)

    # %{"123" => %{metas: [...], username: "jvalim"}, ...}
    for {user_id, %{metas: metas}} <- entries, into: %{} do
      {user_id, %{metas: metas, user: users_map[user_id]}}
    end
  end
end
