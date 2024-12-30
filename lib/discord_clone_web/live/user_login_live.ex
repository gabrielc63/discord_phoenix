defmodule DiscordCloneWeb.UserLoginLive do
  use DiscordCloneWeb, :live_view

  def render(assigns) do
    ~H"""
      <div class="text-center mb-8">
        <h1 class="text-2xl font-bold text-white mb-2">Log in to account</h1>
        <p class="text-gray-400">
          Don't have an account? 
          <.link navigate={~p"/users/register"} class="text-discord-link hover:underline">
            Sign up
          </.link>
        </p>
      </div>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore" class="space-y-6">
        <div class="space-y-2">
          <label for="email" class="uppercase block text-xs font-bold text-gray-300">Email</label>
          <.input field={@form[:email]} type="email" required />
        </div>

        <div class="space-y-2">
          <label for="password" class="block text-sm font-medium text-gray-300 uppercase">Password</label>
          <.input field={@form[:password]} type="password" required />
        </div>

        <:actions>
          <div class="flex items-center">
            <.input field={@form[:remember_me]} type="checkbox" class="w-4 h-4 rounded border-gray-600 text-discord-button focus:ring-discord-button" />
            <label for="remember" class="ml-2 text-sm text-gray-300">
              Keep me logged in
            </label>
          </div>

          <.link href={~p"/users/reset_password"} class="text-sm text-discord-link hover:underline">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2 px-4 rounded-md transition duration-150 ease-in-out">
            Log in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
