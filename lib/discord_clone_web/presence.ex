defmodule DiscordCloneWeb.Presence do
  require Useful

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
    presence_list = Presence.list(server_name)
    %{@user_activity_topic => %{metas: metas}} = presence_list
    Enum.flat_map(metas, fn %{users: users} -> users end)
  end
end
