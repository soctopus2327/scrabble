defmodule Scrabble.Game.Player do
  defstruct players: %{}

  # Create a new game
  def new_game do
    %Scrabble.Game.Player{players: %{}}
  end

  # Add player to the game
  def add_player(game, user_id) do
    cond do
      # Check if game already has 4 players
      map_size(game.players) >= 4 ->
        {:error, "Game is full. Only four players are allowed."}

      # Check if player already exists
      Map.has_key?(game.players, user_id) ->
        {:error, "Player already exists"}

      # Validate user ID format (allowing only alphanumeric and underscores)
      !Regex.match?(~r/^[a-zA-Z0-9_]+$/, user_id) ->
        {:error, "Invalid user ID format. Use only letters, numbers, and underscores"}

      # Add player
      true ->
        # Generate a unique game ID for the player
        game_id = :rand.uniform(9000) + 1000 |> Integer.to_string()

        # Add the player with score and game ID
        players = Map.put(game.players, user_id, %{score: 0, game_id: game_id})
        {:ok, %{game | players: players}}
    end
  end

  # Get the list of players sorted by game ID (for turn management)
  def get_turn_order(game) do
    game.players
    |> Enum.sort_by(fn {_player, data} -> String.to_integer(data.game_id) end)
    |> Enum.map(fn {player, _data} -> player end)
  end

  # Update player score (e.g., based on API input)
  def update_score(game, player_name, points) when is_integer(points) do
    cond do
      map_size(game.players) < 2 ->
        {:error, "Game requires two players to update scores."}

      !Map.has_key?(game.players, player_name) ->
        {:error, "Player not found"}

      true ->
        player_data = game.players[player_name]
        updated_score = player_data.score + points
        updated_players = Map.put(game.players, player_name, Map.put(player_data, :score, updated_score))
        {:ok, %{game | players: updated_players}}
    end
  end

  # Get the current game state (players' scores and game IDs)
  def get_status(game) do
    Enum.map(game.players, fn {player, data} ->
      %{player: player, score: data.score, game_id: data.game_id}
    end)
  end
end

