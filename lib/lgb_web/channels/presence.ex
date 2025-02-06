defmodule LgbWeb.Presence do
  require Logger

  use Phoenix.Presence,
    otp_app: :lgb,
    pubsub_server: Lgb.PubSub

  def init(_opts) do
    {:ok, %{}}
  end

  def fetch(_topic, presences) do
    for {key, %{metas: [meta | metas]}} <- presences, into: %{} do
      # user can be populated here from the database here we populate
      {key, %{metas: [meta | metas], id: meta.id, user: meta}}
    end
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {user_id, presence} <- joins do
      user_data = %{id: user_id, user: presence.user, metas: Map.fetch!(presences, user_id)}
      msg = {__MODULE__, {:join, user_data}}
      Phoenix.PubSub.local_broadcast(Lgb.PubSub, "proxy:#{topic}", msg)
    end

    for {user_id, presence} <- leaves do
      metas =
        case Map.fetch(presences, user_id) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      user_data = %{id: user_id, user: presence.user, metas: metas}
      msg = {__MODULE__, {:leave, user_data}}
      Phoenix.PubSub.local_broadcast(Lgb.PubSub, "proxy:#{topic}", msg)
    end

    {:ok, state}
  end

  def list_online_users(topic),
    do: list(topic) |> Enum.map(fn {_id, presence} -> presence end)

  def track_user(name, topic, params), do: track(self(), topic, name, params)

  def subscribe(topic), do: Phoenix.PubSub.subscribe(Lgb.PubSub, "proxy:#{topic}")

  def find_user(topic, user_id) do
    list(topic) |> Enum.find(fn {_id, presence} -> presence[:id] == user_id end)
  end
end
