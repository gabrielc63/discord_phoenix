defmodule DiscordCloneWeb.UserRegistrationLive do
  use DiscordCloneWeb, :live_view

  alias DiscordClone.Accounts
  alias DiscordClone.Accounts.User

  def render(assigns) do
    ~H"""
    <header class="flex items-center justify-between gap-6">
      <div>
        <h1 class="text-2xl font-bold text-white mb-6">
          Create an account
        </h1>
        <p class="mt-2 text-sm leading-6 text-white">
          Already registered?
          <a href="/users/log_in" data-phx-link="redirect" data-phx-link-state="push" class="font-semibold text-brand hover:underline" data-phx-id="m5-phx-GBV5KSbPxIfVaBoB">
            Log in
          </a>
          to your account now.
        </p>
      </div>
      <div class="flex-none"></div>
    </header>

    <.simple_form
      for={@form}
      id="registration_form"
      phx-submit="save"
      phx-change="validate"
      phx-trigger-action={@trigger_submit}
      action={~p"/users/log_in?_action=registered"}
      method="post"
      class="space-y-6"
    >
      <.error :if={@check_errors}>
        Oops, something went wrong! Please check the errors below.
      </.error>
      <div class="space-y-2">
        <label for="email" class="block text-sm font-medium text-gray-300 uppercase">Email</label>
        <.input field={@form[:email]} type="email"  required />
      </div>

      <div class="space-y-2">
        <label for="username" class="block text-sm font-medium text-gray-300 uppercase">Username</label>
        <.input
          field={@form[:username]}
          type="text"
          required
          class={["w-full px-3 py-2 bg-gray-800 text-white border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"]}
        />
      </div>

      <div class="space-y-2">
        <label for="password" class="block text-sm font-medium text-gray-300 uppercase">Password</label>
        <.input field={@form[:password]} type="password"  required />
      </div>

      <:actions>
        <.button phx-disable-with="Creating account..." class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2 px-4 rounded-md transition duration-150 ease-in-out">
          Conitnue
        </.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
