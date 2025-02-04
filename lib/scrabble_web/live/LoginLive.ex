defmodule ScrabbleWeb.LoginLive do
  use ScrabbleWeb, :live_view
  alias Scrabble.Accounts

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form_data: %{"username" => "", "password" => ""}, error_message: nil)}
  end

  def handle_event("validate", %{"username" => username, "password" => password}, socket) do
    form_data = %{"username" => username, "password" => password}
    {:noreply, assign(socket, form_data: form_data)}
  end

  def handle_event("login", %{"username" => username, "password" => password}, socket) do
    {:noreply, push_navigate(socket, to: "/dashboard")}
    case Accounts.authenticate_user(username, password) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Welcome back!")
         |> push_navigate(to: "/dashboard", session: %{user_id: user.id, user_name: user.userid})}

      {:error, :invalid_username} ->
        {:noreply,
         socket
         |> put_flash(:error, "Username not found")
         |> assign(error_message: "Username not found")}

      {:error, :invalid_password} ->
        {:noreply,
         socket
         |> put_flash(:error, "Incorrect password")
         |> assign(error_message: "Incorrect password")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <h2 class="mt-6 text-center text-3xl font-bold text-gray-900">Sign in to your account</h2>
        <p class="mt-2 text-center text-sm text-gray-600">
          Or
          <.link navigate="/register" class="font-medium text-blue-600 hover:text-blue-500">
            register for a new account
          </.link>
        </p>
      </div>

      <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          <%!-- Add flash messages here --%>
          <%= if live_flash(@flash, :info) do %>
            <div class="mb-4 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative">
              <%= live_flash(@flash, :info) %>
            </div>
          <% end %>

          <%= if live_flash(@flash, :error) do %>
            <div class="mb-4 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative">
              <%= live_flash(@flash, :error) %>
            </div>
          <% end %>

          <form phx-submit="login" phx-change="validate" class="space-y-6">
            <div>
              <label for="username" class="block text-sm font-medium text-gray-700">Username</label>
              <div class="mt-1">
                <input
                  id="username"
                  name="username"
                  type="text"
                  required
                  value={@form_data["username"]}
                  class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                />
              </div>
            </div>

            <div>
              <label for="password" class="block text-sm font-medium text-gray-700">Password</label>
              <div class="mt-1">
                <input
                  id="password"
                  name="password"
                  type="password"
                  required
                  value={@form_data["password"]}
                  class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                />
              </div>
            </div>

            <div>
              <button
                type="submit"
                class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                Sign in
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    """
  end
end
