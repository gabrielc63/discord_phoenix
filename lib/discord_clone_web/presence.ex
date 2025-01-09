defmodule DiscordCloneWeb.Presence do
  require Logger


  use Phoenix.Presence,
    otp_app: :discord_clone,
    pubsub_server: DiscordClone.PubSub

  alias DiscordCloneWeb.Presence

  @user_activity_topic "user_activity"

  def track_user(pid, server_name, user_data) do
    Presence.track(
      pid,
      server_name,
      @user_activity_topic,
      %{users: [user_data]}
    )  
  end

  def list_users(server_name) do
    result = Presence.list(server_name) |> Enum.map(&extract_server_with_users/1)
    [{topic, users_list}] = result
    users_list
  end

  defp extract_server_with_users({server_name, %{metas: metas}}) do
    {server_name, users_from_metas_list(metas)}
  end

  defp users_from_metas_list(metas_list) do
    Enum.map(metas_list, &users_from_meta_map/1)
      |> List.flatten()
  end

  defp users_from_meta_map(meta_map) do
    get_in(meta_map, [:users])
  end
end
