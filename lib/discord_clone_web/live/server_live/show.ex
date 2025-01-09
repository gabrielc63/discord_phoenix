defmodule DiscordCloneWeb.ServerLive.Show do
  require Logger
  use DiscordCloneWeb, :live_view
  alias DiscordClone.Servers
  alias DiscordClone.Channels
  alias DiscordCloneWeb.Presence
  alias Phoenix.Socket.Broadcast


  @impl true
  def mount(%{"id" => server_id}, _session, socket) do
    server = Servers.get_server!(server_id)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(DiscordClone.PubSub, "chat:lobby")
      Phoenix.PubSub.subscribe(DiscordClone.PubSub, server.name)

      username = socket.assigns.current_user.username

      {:ok, _} =  Presence.track_user(self(), server.name, %{
        username: username,
        online_at: DateTime.utc_now()
      })
    end

    channels = Channels.list_channels(server_id)
    current_channel = List.first(channels).name
    servers = Servers.list_servers()
    users = Presence.list_users(server.name)

    {:ok,
     assign(socket,
       messages: [],
       current_message: "",
       channels: channels,
       current_channel: current_channel,
       online_users: users,
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
  def handle_info(%Broadcast{event: "presence_diff"} = _event, socket) do
    online_users = Presence.list_users(socket.assigns.server.name)

    {:noreply, assign(socket, :online_users, online_users)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex h-screen bg-gray-800 text-gray-100">
      <!-- Servers Sidebar -->
      <div class="w-16 bg-gray-900 flex flex-col items-center py-3 space-y-3">
        <%= for server <- @servers do %>
          <.link  patch={~p"/servers/#{server}"} class="block">
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
            <div class="flex-1">
              <div class="text-sm font-medium"><%= @current_user.username %></div>
              <div class="text-discord-channel text-xs">Online</div>
            </div>
            <div class="flex space-x-2 text-discord-channel">
              <i class="fas fa-microphone cursor-pointer hover:text-gray-300"></i>
              <i class="fas fa-headphones cursor-pointer hover:text-gray-300"></i>
              <i class="fas fa-cog cursor-pointer hover:text-gray-300"></i>
            </div>
          </div>
        </div>
      </div>

      <!-- Main Chat Area -->
      <div class="flex-1 flex flex-col bg-discord-primary">


        <!-- Channel Header -->
        <div class="h-12 border-b border-gray-800 flex items-center px-4 shadow-sm">
          <i class="fas fa-hashtag text-discord-channel mr-2"></i>
          <span class="text-white font-bold"><%= @current_channel %></span>
        </div>

        <div class="flex-1 overflow-y-auto p-4 space-y-4">
          <%= for message <- Enum.reverse(@messages) do %>
            <%= if message.channel == @current_channel do %>
              <div class="flex items-start space-x-4">
                <div class="w-10 h-10 rounded-full bg-gray-700 flex-shrink-0"></div>
                <div>
                  <div class="flex items-baseline space-x-2">
                    <span class="font-bold"><%= message.user.username %></span>
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
          <div class="flex items-center bg-discord-hover rounded-lg p-4">
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

      <!-- Online Users Sidebar -->
      <div class="w-60 bg-discord-secondary flex flex-col">
          <div class="p-4 shadow-md">
              <h2 class="text-white font-bold">Online - <%= length(@online_users) %></h2>
          </div>
          <div class="flex-1 overflow-y-auto">
              <!-- Online Users List -->
          <div class="px-2 pt-4 space-y-2">
                  <%= for user <- @online_users do %>
                  <div class="flex items-center px-2 py-1 text-discord-channel hover:bg-discord-hover rounded cursor-pointer">
                      <div class="w-8 h-8 rounded-full bg-blue-500 mr-2 relative">
                          <div class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 rounded-full border-2 border-discord-secondary"></div>
                      </div>
                      <span class="text-white">
                        <%= user.username %>
                        <%= if user.username == @current_user.username do %>
                        (you)
                        <% end %>
                      </span>
                  </div>
                  <% end %>
              </div>
          </div>
      </div>

    </div>
    
    """
  end
end
