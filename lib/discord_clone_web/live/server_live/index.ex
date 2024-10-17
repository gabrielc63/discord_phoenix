defmodule DiscordCloneWeb.ServerLive.Index do
  use DiscordCloneWeb, :live_view
  alias DiscordClone.Servers

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()
    {:ok, assign(socket, servers: servers)}
  end

  def render(assigns) do
    ~H"""
    <h1>List of servers</h1>
    <ul>
      <%= for server <- @servers do %>
        <li>
          <%= live_patch(server.name, to: ~p"/servers/#{server}") %>
        </li>
      <% end %>
    </ul>
    """
  end
end
