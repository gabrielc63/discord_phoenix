defmodule DiscordCloneWeb.LiveAuth do
  import Phoenix.LiveView

  alias DiscordClone.Accounts
  alias DiscordClone.Accounts.User
  alias DiscordCloneWeb.Router.Helpers, as: Routes

  def on_mount(:require_authenticated_user, _, session, socket) do
    socket = assign_current_user(socket, session)

    case socket.assigns.current_user do
      nil ->
        {:halt,
         socket
         |> put_flash(:error, "You have to sign in to continue.")
         |> redirect(to: Routes.user_session_path(socket, :new))}

      %User{} ->
        {:cont, socket}
    end
  end

  defp assign_current_user(socket, session) do
    case session do
      %{"user_token" => user_token} ->
        Phoenix.Component.assign_new(socket, :current_user, fn ->
          Accounts.get_user_by_session_token(user_token)
        end)

      %{} ->
        Phoenix.Component.assign_new(socket, :current_user, fn -> nil end)
    end
  end
end
