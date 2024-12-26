defmodule DiscordCloneWeb.ServerLive.Show do
  use DiscordCloneWeb, :live_view
  alias DiscordClone.Servers
  alias DiscordClone.Channels

  @impl true
  def mount(%{"id" => server_id}, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(DiscordClone.PubSub, "chat:lobby")
    end

    server = Servers.get_server!(server_id)
    servers = Servers.list_servers()
    channels = Channels.list_channels(server_id)

    {:ok,
     assign(socket,
       messages: [],
       current_message: "",
       channels: channels,
       current_channel: List.first(channels).name,
       online_users: [],
       server: server,
       servers: servers,
       channels: channels
     )}
  end

  @impl true
  def handle_event("typing", %{"value" => value}, socket) do
    {:noreply, assign(socket, current_message: value)}
  end

  @impl true
  def handle_event("send_message", %{"message" => content}, socket) do
    message = %{
      id: System.unique_integer(),
      content: content,
      user: socket.assigns.current_user,
      timestamp: DateTime.utc_now(),
      channel: socket.assigns.current_channel
    }

    Phoenix.PubSub.broadcast(DiscordClone.PubSub, "chat:lobby", {:new_message, message})
    {:noreply, assign(socket, current_message: "")}
  end

  @impl true
  def handle_event("switch_channel", %{"channel" => channel}, socket) do
    {:noreply, assign(socket, current_channel: channel)}
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    {:noreply, update(socket, :messages, &[message | &1])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex h-screen bg-gray-800 text-gray-100">
      <div class="w-16 bg-gray-900 flex flex-col items-center py-3 space-y-3">
        <%= for server <- @servers do %>
          <%= live_patch to: ~p"/servers/#{server}", class: "block" do %>
            <div class="w-12 h-12 bg-gray-700 rounded-full flex items-center justify-center">
              <span class="text-xl font-bold"><%= String.at(server.name, 0) %></span>
            </div>
          <% end %>
        <% end %>

        <div class="w-12 h-1 bg-gray-700 rounded-full" />
        <button class="w-12 h-12 bg-gray-700 rounded-full flex items-center justify-center hover:bg-green-500 transition-colors">
          +
        </button>
      </div>
      <!-- Channels Sidebar -->
      <div class="w-60 bg-gray-800 flex flex-col">
        <div class="p-4 shadow-md">
          <h1 class="font-bold"><%= @server.name %></h1>
        </div>
        <div class="flex-1 overflow-y-auto">
          <%= for channel <- @channels do %>
            <div
              class={"flex items-center px-2 py-1 mx-2 rounded cursor-pointer #{if @current_channel == channel, do: "bg-gray-700"}"}
              phx-click="switch_channel"
              phx-value-channel={channel.name}
            >
              <span class="mr-2">#</span>
              <span><%= channel.name %></span>
            </div>
          <% end %>
        </div>
        <div class="p-4 bg-gray-900">
          <div class="flex items-center space-x-2">
            <div class="w-8 h-8 bg-gray-700 rounded-full"></div>
            <div>
              <div class="text-sm font-medium"><%= @current_user.email %></div>
            </div>
          </div>
        </div>
      </div>
      <!-- Main Chat Area -->
      <div class="flex-1 flex flex-col">
        <div class="p-4 shadow-md flex items-center">
          <span class="mr-2">#</span>
          <span class="font-bold"><%= @current_channel %></span>
        </div>

        <div class="flex-1 overflow-y-auto p-4 space-y-4">
          <%= for message <- Enum.reverse(@messages) do %>
            <%= if message.channel == @current_channel do %>
              <div class="flex items-start space-x-4">
                <div class="w-10 h-10 rounded-full bg-gray-700 flex-shrink-0"></div>
                <div>
                  <div class="flex items-baseline space-x-2">
                    <span class="font-bold"><%= message.user.email %></span>
                    <span class="text-xs text-gray-400">
                      <%= Calendar.strftime(message.timestamp, "%H:%M") %>
                    </span>
                  </div>
                  <p class="text-gray-300"><%= message.content %></p>
                </div>
              </div>
            <% end %>
          <% end %>
        </div>

        <form phx-submit="send_message" class="p-4">
          <div class="flex items-center bg-gray-700 rounded-lg px-4 py-2">
            <input
              type="text"
              name="message"
              value={@current_message}
              placeholder={"Message ##{@current_channel}"}
              class="flex-1 bg-transparent outline-none"
              autocomplete="off"
              phx-keyup="typing"
            />
            <button type="submit" class="ml-2">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
                />
              </svg>
            </button>
          </div>
        </form>
      </div>
    </div>
    """
  end
end
