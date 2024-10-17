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
    <div class="text-gray-300">
      <h1 class="text-white font-bold text-xl p-4 shadow-md"><%= @server.name %></h1>
      <div class="px-2 py-3">
        <h2 class="text-gray-500 uppercase text-xs font-semibold px-2 mb-2">Text Channels</h2>
        <ul>
          <%= for channel <- @channels do %>
            <li class="px-2">
              <%= live_patch to: ~p"/servers/#{@server}/channels/#{channel}", class: "flex items-center text-gray-400 hover:text-gray-200 hover:bg-gray-700 px-2 py-1 rounded" do %>
                <span class="text-xl mr-1">#</span>
                <%= channel.name %>
              <% end %>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end
end
