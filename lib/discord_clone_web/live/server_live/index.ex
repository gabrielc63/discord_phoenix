defmodule DiscordCloneWeb.ServerLive.Index do
  use DiscordCloneWeb, :live_view
  alias DiscordClone.Servers

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()
    {:ok, assign(socket, servers: servers)}
  end

  def render(assigns) do
    ~H"""
    <div class="py-2">
      <h1 class="text-white font-bold text-xl px-4 mb-2">Servers</h1>
      <ul class="flex flex-row sm:flex-col overflow-x-auto sm:overflow-x-visible">
        <%= for server <- @servers do %>
          <li class="px-2 py-1">
            <%= live_patch to: ~p"/servers/#{server}", class: "block" do %>
              <div class="w-12 h-12 rounded-full bg-gray-700 flex items-center justify-center text-white font-bold hover:bg-indigo-500 transition-colors">
                <%= String.at(server.name, 0) %>
              </div>
            <% end %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
