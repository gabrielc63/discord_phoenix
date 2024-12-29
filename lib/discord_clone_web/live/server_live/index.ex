defmodule DiscordCloneWeb.ServerLive.Index do
  use DiscordCloneWeb, :live_view
  alias DiscordClone.Servers

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()
    {:ok, assign(socket, servers: servers)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex h-screen bg-gray-800 text-gray-100">
      <div class="w-16 bg-gray-900 flex flex-col items-center py-3 space-y-3">
        <%= for server <- @servers do %>
          <.link patch={~p"/servers/#{server}"} class="block">
            <div class="w-12 h-12 bg-gray-700 rounded-full flex items-center justify-center">
              <span class="text-xl font-bold"><%= String.at(server.name, 0) %></span>
            </div>
          </.link>
        <% end %>

        <div class="w-12 h-1 bg-gray-700 rounded-full" />
        <button class="w-12 h-12 bg-gray-700 rounded-full flex items-center justify-center hover:bg-green-500 transition-colors">
          +
        </button>
      </div>
    </div>
    """
  end
end
