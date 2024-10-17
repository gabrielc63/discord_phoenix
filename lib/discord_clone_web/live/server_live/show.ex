defmodule DiscordCloneWeb.ServerLive.Show do
  use DiscordCloneWeb, :live_view
  alias DiscordClone.Servers
  alias DiscordClone.Channels

  def mount(%{"id" => server_id}, _session, socket) do
    server = Servers.get_server!(server_id)
    channels = Channels.list_channels(server_id)
    {:ok, assign(socket, server: server, channels: channels)}
  end

  def render(assigns) do
    ~H"""
    <h1><%= @server.name %> Channels</h1>
    <br />
    <ul>
      <%= for channel <- @channels do %>
        <li>
          <%= live_patch(channel.name, to: ~p"/servers/#{@server}/channels/#{channel}") %>
        </li>
      <% end %>
    </ul>
    """
  end
end
