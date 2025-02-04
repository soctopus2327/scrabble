defmodule ScrabbleWeb.DashboardLive do
  use ScrabbleWeb, :live_view
  alias Scrabble.Repo
  alias Scrabble.User
  import Ecto.Query, only: [from: 2]
  import Phoenix.LiveView.JS

  def mount(_params, _session, socket) do

    leaderboard =
      from(u in User,
        order_by: [desc: u.score],
        select: %{userid: u.userid, score: u.score}
      )
      |> Repo.all()

      {:ok, assign(socket, leaderboard: leaderboard, show_join_modal: false, generated_code: nil, show_create_modal: false, room_code: nil, error_message: nil)}

  end

  def handle_event("copy_to_clipboard", _, socket) do
    {:noreply, assign(socket, copied_to_clipboard: true)}
  end


  def handle_event("show_join_modal", _, socket) do
    {:noreply, assign(socket, show_join_modal: true)}
  end

  def handle_event("hide_join_modal", _, socket) do
    {:noreply, assign(socket, show_join_modal: false)}
  end

  def handle_event("create_game", _, socket) do
    game_code = generate_unique_code()
    {:noreply,
     socket
     |> assign(show_create_modal: true, generated_code: game_code)}
  end

  def handle_event("start_game", %{"code" => code}, socket) do
    {:noreply, push_navigate(socket, to: "/game/#{code}")}
  end

  def handle_event("join_game", %{"room_code" => room_code}, socket) do
    case Repo.get_by(Game, code: room_code) do
      nil ->  # Game with that code doesn't exist
        {:noreply, assign(socket, error_message: "Room does not exist")}
      game ->  # Game exists
        {:noreply, push_navigate(socket, to: "/game/#{game.code}")}  # Redirect to game page
    end
  end

  def handle_event("close_create_modal", _, socket) do
    {:noreply, assign(socket, show_create_modal: false, generated_code: nil)}
  end

  def handle_event("update_room_code", %{"room_code" => room_code}, socket) do
    {:noreply, assign(socket, room_code: room_code)}
  end

  defp generate_unique_code() do
    :crypto.strong_rand_bytes(4) |> Base.url_encode64() |> binary_part(0, 6)
  end


  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100">
      <div class="py-6">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h1 class="text-3xl font-bold text-gray-900 mb-8">Scrabble Dashboard</h1>

          <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div class="lg:col-span-2">
              <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-xl font-semibold mb-6">Game Options</h2>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div class="bg-gray-50 p-6 rounded-lg border-2 border-gray-200 hover:border-blue-500 cursor-pointer transition-colors">
                    <button phx-click="create_game" class="w-full h-full text-center">
                      <div class="text-xl font-semibold mb-2">Create Game</div>
                      <p class="text-gray-600">Start a new game and invite friends</p>
                    </button>
                  </div>

                  <div class="bg-gray-50 p-6 rounded-lg border-2 border-gray-200 hover:border-blue-500 cursor-pointer transition-colors">
                    <button phx-click="show_join_modal" class="w-full h-full text-center">
                      <div class="text-xl font-semibold mb-2">Join Game</div>
                      <p class="text-gray-600">Enter a room code to join friends</p>
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div class="lg:col-span-1">
              <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-xl font-semibold mb-6">Leaderboard</h2>
                <div class="space-y-4">
                  <%= for {player, index} <- Enum.with_index(@leaderboard) do %>
                    <div class={"flex items-center justify-between p-3 #{if index == 0, do: "bg-yellow-50", else: "bg-gray-50"} rounded-lg"}>
                      <div class="flex items-center space-x-3">
                        <span class="font-semibold"><%= index + 1 %>.</span>
                        <span class="font-medium"><%= player.userid %></span>
                      </div>
                      <div class="text-gray-600">
                        <span>Score: <%= player.score %></span>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Create Game Modal -->
      <%= if @show_create_modal do %>
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center" id="create-modal">
          <div class="bg-white p-6 rounded-lg shadow-xl w-full max-w-md">
            <h3 class="text-lg font-semibold mb-4">Game Created!</h3>
            <p class="mb-4">Share this code with your friends to join the game:</p>
            <div class="flex items-center justify-between bg-gray-100 px-3 py-2 rounded-lg mb-4">
              <span class="font-mono text-gray-700" id="game-code"><%= @generated_code %></span>
              <button
                class="text-sm font-medium text-blue-600 hover:underline"
                phx-click={JS.exec("navigator.clipboard.writeText('#{@generated_code}')")}
              >
                Copy
              </button>
            </div>
            <div class="flex justify-end space-x-3">
              <button
                type="button"
                phx-click="close_create_modal"
                class="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-md"
              >
                Close
              </button>
              <button
                type="button"
                phx-click="start_game"
                phx-value-code={@generated_code}
                class="px-4 py-2 text-sm font-medium text-white bg-green-600 hover:bg-green-700 rounded-md"
              >
                Start Game
              </button>
            </div>
          </div>
        </div>
      <% end %>

      <!-- Join Game Modal -->
    <%= if @show_join_modal do %>
      <div class="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center">
        <div class="bg-white p-6 rounded-lg shadow-xl w-full max-w-md" id="join-modal">
          <h3 class="text-lg font-semibold mb-4">Join Game</h3>
          <p class="mb-4">Enter the room code:</p>
          <form phx-submit="join_game">
            <div class="mb-4">
              <input
                type="text"
                class="w-full px-4 py-2 border rounded-lg"
                placeholder="Room Code"
                value={@room_code}
                phx-change="update_room_code"
                id="room-code-input"
              />
            </div>
            <%= if @error_message do %>
              <p class="text-red-600 text-sm mt-2"><%= @error_message %></p>
            <% end %>
            <div class="flex justify-end space-x-3">
              <button
                type="button"
                phx-click="hide_join_modal"
                class="px-4 py-2 text-sm font-medium text-white bg-gray-600 hover:bg-gray-700 rounded-md"
              >
                Close
              </button>
              <button
                type="submit"
                class="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-md"
              >
                Join Game
              </button>
            </div>
          </form>
        </div>
      </div>
    <% end %>

    </div>
    """
  end


end
