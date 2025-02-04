defmodule ScrabbleWeb.GameLive do
  use ScrabbleWeb, :live_view
  alias Scrabble.Game

  @dictionary_words (
    "priv/dictionary/sowpods.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> MapSet.new()
  )

  @spec mount(any(), any(), any()) :: {:ok, any()}
  def mount(_params, _session, socket) do
    game = Game.new_game()

    {:ok,
      assign(socket,
        board: game.board,
        rack_tiles: game.rack_tiles,
        rack_tiles_player2: Game.draw_tiles(7),
        score_player1: 0,
        score_player2: 0,
        placed_tiles: %{},
        locked_tiles: false,
        current_player: :player1,
        game_started: false,
        current_direction: nil
      )}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-8">Scrabble</h1>

      <div class="flex gap-2">
      <!-- Score Display -->
      <div class="flex score-flex">
        <div class={["score-box p-4 rounded-lg shadow-md",
          @current_player == :player1 && "bg-green-100" || "bg-white"]}>
          <p class="text-xl font-semibold">Player 1</p>
          <p class="text-xl font-semibold">Score: <%= @score_player1 %></p>
          <%= if @current_player == :player1 do %>
            <p class="text-sm text-green-600">Current Turn</p>
          <% end %>
        </div>
        <div class={["score-box p-4 rounded-lg shadow-md",
          @current_player == :player2 && "bg-green-100" || "bg-white"]}>
          <p class="text-xl font-semibold">Player 2</p>
          <p class="text-xl font-semibold">Score: <%= @score_player2 %></p>
          <%= if @current_player == :player2 do %>
            <p class="text-sm text-green-600">Current Turn</p>
          <% end %>
        </div>
      </div>

        <!-- Main Game Area -->
        <div class="flex-1 board-area">
          <!-- Scrabble Board -->
          <div class="grid grid-cols-15 gap-1 bg-gray-300 p-1 rounded-lg"
              id="scrabble-board"
              phx-hook="BoardHook">
            <%= for {row, row_idx} <- Enum.with_index(@board) do %>
              <%= for {cell, col_idx} <- Enum.with_index(row) do %>
                <div class={cell_classes(cell)}
                    data-row={row_idx}
                    data-col={col_idx}
                    phx-value-row={row_idx}
                    phx-value-col={col_idx}>
                  <%= if cell.letter do %>
                    <div class="tile-placed tile">
                      <span class="letter"><%= cell.letter %></span>
                      <span class="points"><%= cell.points %></span>
                    </div>
                  <% else %>
                    <%= if Map.get(@placed_tiles, {row_idx, col_idx}) do %>
                      <% placed_tile = Map.get(@placed_tiles, {row_idx, col_idx}) %>
                      <div class="tile"
                          draggable={if @locked_tiles, do: "false", else: "true"}
                          data-row={row_idx}
                          data-col={col_idx}>
                        <span class="letter"><%= placed_tile.letter %></span>
                        <span class="points"><%= placed_tile.points %></span>
                      </div>
                    <% end %>
                    <%= if cell.bonus in [:triple_word, :double_word, :triple_letter, :double_letter, :center] do %>
                      <span class="bonus-label">
                        <%= bonus_label(cell.bonus) %>
                      </span>
                    <% end %>
                  <% end %>
                </div>
              <% end %>
            <% end %>
          </div>

          <!-- Tile Rack -->
      <div class="mt-8 flex flex-col items-center gap-4">
        <div class="bg-wood p-4 rounded-lg flex gap-2" id="tile-rack" phx-hook="RackHook">
          <%= for {tile, idx} <- Enum.with_index(
            if(@current_player == :player1, do: @rack_tiles, else: @rack_tiles_player2)
          ) do %>
            <div class="tile"
                draggable="true"
                data-tile-idx={idx}
                data-letter={tile.letter}>
              <span class="letter"><%= tile.letter %></span>
              <span class="points"><%= tile.points %></span>
            </div>
          <% end %>
        </div>

            <!-- Submit Button -->
            <div class="flex gap-1">
              <button class="bg-blue-200 text-black px-2 py-1 rounded"
                      phx-click="resign">
                Resign
              </button>
              <button class="bg-blue-500 text-white px-2 py-1 rounded"
                      phx-click="submit-tiles"
                      disabled={map_size(@placed_tiles) == 0}>
                Submit
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp cell_classes(cell) do
    base = "w-16 h-16 flex items-center justify-center relative border border-gray-300"
    bonus = case cell.bonus do
      :triple_word -> " bg-red-300"
      :double_word -> " bg-pink-300"
      :triple_letter -> " bg-blue-300"
      :double_letter -> " bg-light-blue-300"
      :center -> " bg-yellow-200"
      :normal -> " bg-gray-50"
    end
    base <> bonus
  end

  defp bonus_label(bonus) do
    case bonus do
      :triple_word -> "TW"
      :double_word -> "DW"
      :triple_letter -> "TL"
      :double_letter -> "DL"
      :center -> "★"
      _ -> ""
    end
  end

  def handle_event("tile-dropped", %{"letter" => letter, "row" => row, "col" => col}, socket) do
    row = String.to_integer(row)
    col = String.to_integer(col)

    cond do
      not valid_move?(socket.assigns.board, row, col) ->
        {:noreply, put_flash(socket, :error, "Invalid move!")}

      not valid_placement?(socket.assigns, row, col) ->
        {:noreply, put_flash(socket, :error, "Tiles must be placed in a single line!")}

      true ->
        current_rack = case socket.assigns.current_player do
          :player1 -> socket.assigns.rack_tiles
          :player2 -> socket.assigns.rack_tiles_player2
        end

        tile_to_remove = Enum.find(current_rack, fn tile ->
          tile.letter == letter
        end)

        if tile_to_remove do
          current_direction = determine_direction(socket.assigns.placed_tiles, row, col)

          placed_tiles = Map.put(
            socket.assigns.placed_tiles,
            {row, col},
            tile_to_remove
          )

          updated_assigns = case socket.assigns.current_player do
            :player1 ->
              %{rack_tiles: List.delete(socket.assigns.rack_tiles, tile_to_remove)}
            :player2 ->
              %{rack_tiles_player2: List.delete(socket.assigns.rack_tiles_player2, tile_to_remove)}
          end

          {:noreply,
           socket
           |> assign(updated_assigns)
           |> assign(
             placed_tiles: placed_tiles,
             current_direction: current_direction || socket.assigns.current_direction
           )}
        else
          {:noreply, socket}
        end
    end
  end

  def handle_event("submit-tiles", _params, socket) do
    IO.puts("Submit tiles event triggered") # Debug log

    case validate_move(socket.assigns) do
      {:error, message} ->
        IO.puts("Validation error: #{message}") # Debug log
        {:noreply, put_flash(socket, :error, message)}

      :ok ->
        IO.puts("Move validation passed")
        with {:ok, words} <- get_formed_words(socket.assigns),
             {:ok, score} <- calculate_score(socket.assigns) do

          IO.puts("Words formed: #{inspect(words)}")
          IO.puts("Score calculated: #{score}")

          {current_rack, other_rack} = case socket.assigns.current_player do
            :player1 ->
              current_tiles = socket.assigns.rack_tiles
              {current_tiles -- Map.values(socket.assigns.placed_tiles),
               socket.assigns.rack_tiles_player2}
            :player2 ->
              current_tiles = socket.assigns.rack_tiles_player2
              {current_tiles -- Map.values(socket.assigns.placed_tiles),
               socket.assigns.rack_tiles}
          end

          tiles_needed = 7 - length(current_rack)

          new_tiles = if tiles_needed > 0, do: Game.draw_tiles(tiles_needed), else: []
          IO.puts("Drawing #{tiles_needed} new tiles")

          updated_rack = current_rack ++ new_tiles
          IO.puts("Updated rack size: #{length(updated_rack)}")

          updated_board = commit_tiles_to_board(socket.assigns)

          socket = socket
          |> assign(:board, updated_board)
          |> update(
            (if socket.assigns.current_player == :player1, do: :score_player1, else: :score_player2),
            &(&1 + score)
          )
          |> assign(
            case socket.assigns.current_player do
              :player1 -> %{
                rack_tiles: updated_rack,
                rack_tiles_player2: other_rack
              }
              :player2 -> %{
                rack_tiles: other_rack,
                rack_tiles_player2: updated_rack
              }
            end
          )
          |> assign(
            placed_tiles: %{},
            locked_tiles: false,
            current_player: opposite_player(socket.assigns.current_player),
            current_direction: nil,
            game_started: true
          )
          |> put_flash(:info, "Move submitted! Score: #{score}")

          {:noreply, socket}
        else
          {:error, message} ->
            IO.puts("Error processing move: #{message}")
            {:noreply, put_flash(socket, :error, message)}
        end
    end
  end

  defp valid_move?(board, row, col) do
    cell = board |> Enum.at(row) |> Enum.at(col)
    is_nil(cell.letter)
  end

  defp valid_placement?(assigns, row, col) do
    case {map_size(assigns.placed_tiles), assigns.current_direction} do
      {0, _} ->
        if not assigns.game_started do
          row == 7 and col == 7
        else
          true
        end
      {1, nil} ->
        has_adjacent_placed_tile?(assigns.placed_tiles, row, col)
        true
      {_, :horizontal} ->
        Enum.all?(assigns.placed_tiles, fn {{existing_row, _}, _} ->
          existing_row == row
        end) && has_adjacent_placed_tile?(assigns.placed_tiles, row, col)
        true
      {_, :vertical} ->
        Enum.all?(assigns.placed_tiles, fn {{_, existing_col}, _} ->
          existing_col == col
        end) && has_adjacent_placed_tile?(assigns.placed_tiles, row, col)
        true
    end
  end

  defp determine_direction(placed_tiles, new_row, new_col) do
    case map_size(placed_tiles) do
      0 -> nil
      1 ->
        [{existing_row, existing_col}] = Map.keys(placed_tiles)
        cond do
          existing_row == new_row -> :horizontal
          existing_col == new_col -> :vertical
          true -> nil
        end
      _ ->
        if Map.has_key?(placed_tiles, {new_row, new_col}) do
          nil
        else
          get_existing_direction(placed_tiles)
        end
    end
  end

  defp get_existing_direction(placed_tiles) do
    positions = Map.keys(placed_tiles)
    first_pos = List.first(positions)
    if Enum.all?(positions, fn {row, _} -> row == elem(first_pos, 0) end) do
      :horizontal
    else
      :vertical
    end
  end

  defp has_adjacent_placed_tile?(placed_tiles, row, col) do
    [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
    |> Enum.any?(fn {dx, dy} ->
      Map.has_key?(placed_tiles, {row + dx, col + dy})
    end)
  end

  # defp get_formed_words(assigns) do
  #   main_word = get_word_at_placement(assigns)
  #   cross_words = get_cross_words(assigns)

  #   if valid_word_placement?(assigns, main_word) do
  #     {:ok, [main_word | cross_words]}
  #   else
  #     {:error, "Invalid word placement"}
  #   end
  # end

  defp get_word_at_placement(assigns) do
    case assigns.current_direction do
      :horizontal -> get_horizontal_word(assigns)
      :vertical -> get_vertical_word(assigns)
      nil ->
        if map_size(assigns.placed_tiles) == 1 do
          # Single letter placement
          {_, tile} = Enum.at(assigns.placed_tiles, 0)
          tile.letter
        else
          ""
        end
    end
  end

  defp get_horizontal_word(assigns) do
    {row, _} = assigns.placed_tiles |> Map.keys() |> List.first()

    cols = assigns.placed_tiles
    |> Map.keys()
    |> Enum.filter(fn {r, _} -> r == row end)
    |> Enum.map(fn {_, c} -> c end)

    min_col = Enum.min(cols)
    max_col = Enum.max(cols)

    min_col..max_col
    |> Enum.map(fn col ->
      cond do
        tile = assigns.placed_tiles[{row, col}] -> tile.letter
        cell = get_in(assigns.board, [Access.at(row), Access.at(col)]) -> cell.letter || ""
        true -> ""
      end
    end)
    |> Enum.join("")
  end

  defp get_vertical_word(assigns) do
    {_, col} = assigns.placed_tiles |> Map.keys() |> List.first()

    rows = assigns.placed_tiles
    |> Map.keys()
    |> Enum.filter(fn {_, c} -> c == col end)
    |> Enum.map(fn {r, _} -> r end)

    min_row = Enum.min(rows)
    max_row = Enum.max(rows)

    min_row..max_row
    |> Enum.map(fn row ->
      cond do
        tile = assigns.placed_tiles[{row, col}] -> tile.letter
        cell = get_in(assigns.board, [Access.at(row), Access.at(col)]) -> cell.letter || ""
        true -> ""
      end
    end)
    |> Enum.join("")
  end

  defp get_cross_words(assigns) do
    assigns.placed_tiles
    |> Map.keys()
    |> Enum.flat_map(fn {row, col} ->
      case assigns.current_direction do
        :horizontal -> [get_vertical_word_at(assigns, row, col)]
        :vertical -> [get_horizontal_word_at(assigns, row, col)]
        nil -> []
      end
    end)
    |> Enum.filter(&(String.length(&1) > 1))
  end

  defp get_horizontal_word_at(assigns, row, col) do
    start_col = find_word_start(assigns, row, col, fn c -> c - 1 end)
    end_col = find_word_end(assigns, row, col, fn c -> c + 1 end)

    start_col..end_col
    |> Enum.map(fn c ->
      cond do
        tile = assigns.placed_tiles[{row, c}] -> tile.letter
        cell = get_in(assigns.board, [Access.at(row), Access.at(c)]) -> cell.letter || ""
        true -> ""
      end
    end)
    |> Enum.join("")
  end

  defp get_vertical_word_at(assigns, row, col) do
    start_row = find_word_start(assigns, row, col, fn r -> r - 1 end)
    end_row = find_word_end(assigns, row, col, fn r -> r + 1 end)

    start_row..end_row
    |> Enum.map(fn r ->
      cond do
        tile = assigns.placed_tiles[{r, col}] -> tile.letter
        cell = get_in(assigns.board, [Access.at(r), Access.at(col)]) -> cell.letter || ""
        true -> ""
      end
    end)
    |> Enum.join("")
  end

  defp find_word_start(assigns, pos, fixed, next_fn) do
    if has_letter_at?(assigns, pos, fixed) && pos > 0 do
      find_word_start(assigns, next_fn.(pos), fixed, next_fn)
    else
      pos
    end
  end

  defp find_word_end(assigns, pos, fixed, next_fn) do
    if has_letter_at?(assigns, pos, fixed) && pos < 14 do
      find_word_end(assigns, next_fn.(pos), fixed, next_fn)
    else
      pos
    end
  end

  defp has_letter_at?(assigns, row, col) do
    case assigns.placed_tiles[{row, col}] do
      nil ->
        case get_in(assigns.board, [Access.at(row), Access.at(col)]) do
          nil -> false
          cell -> not is_nil(cell.letter)
        end
      _ -> true
    end
  end

  defp validate_words(words) do
    invalid_words = Enum.reject(words, fn word ->
      word = String.upcase(word)
      MapSet.member?(@dictionary_words, word)
    end)

    if Enum.empty?(invalid_words) do
      {:ok, true}
    else
      {:error, "Invalid words: #{Enum.join(invalid_words, ", ")}"}
    end
  end

  defp valid_word_placement?(assigns, word) do
    cond do
      not assigns.game_started ->
        uses_center_square?(assigns.placed_tiles)

      true -> :true
    end
  end

  defp calculate_score(assigns) do
    main_word_score = calculate_word_score(assigns, assigns.current_direction)

    cross_words_score = assigns.placed_tiles
    |> Map.keys()
    |> Enum.map(fn {row, col} ->
      case assigns.current_direction do
        :horizontal -> calculate_vertical_word_score(assigns, row, col)
        :vertical -> calculate_horizontal_word_score(assigns, row, col)
        nil -> 0
      end
    end)
    |> Enum.sum()

    {:ok, main_word_score + cross_words_score}
  end

  defp calculate_word_score(assigns, :horizontal) do
    {row, _} = assigns.placed_tiles |> Map.keys() |> List.first()

    cols = assigns.placed_tiles
    |> Map.keys()
    |> Enum.filter(fn {r, _} -> r == row end)
    |> Enum.map(fn {_, c} -> c end)

    min_col = Enum.min(cols)
    max_col = Enum.max(cols)

    {base_score, word_multiplier} = min_col..max_col
    |> Enum.reduce({0, 1}, fn col, {score, multiplier} ->
      cell = get_in(assigns.board, [Access.at(row), Access.at(col)])
      letter = (assigns.placed_tiles[{row, col}] || %{letter: cell.letter, points: cell.points}).letter
      points = (assigns.placed_tiles[{row, col}] || %{letter: cell.letter, points: cell.points}).points

      case cell.bonus do
        :triple_word -> {score + points, multiplier * 3}
        :double_word -> {score + points, multiplier * 2}
        :triple_letter -> {score + (points * 3), multiplier}
        :double_letter -> {score + (points * 2), multiplier}
        _ -> {score + points, multiplier}
      end
    end)

    base_score * word_multiplier
  end

  defp calculate_word_score(assigns, :vertical) do
    {_, col} = assigns.placed_tiles |> Map.keys() |> List.first()

    rows = assigns.placed_tiles
    |> Map.keys()
    |> Enum.filter(fn {_, c} -> c == col end)
    |> Enum.map(fn {r, _} -> r end)

    min_row = Enum.min(rows)
    max_row = Enum.max(rows)

    {base_score, word_multiplier} = min_row..max_row
    |> Enum.reduce({0, 1}, fn row, {score, multiplier} ->
      cell = get_in(assigns.board, [Access.at(row), Access.at(col)])
      letter = (assigns.placed_tiles[{row, col}] || %{letter: cell.letter, points: cell.points}).letter
      points = (assigns.placed_tiles[{row, col}] || %{letter: cell.letter, points: cell.points}).points

      case cell.bonus do
        :triple_word -> {score + points, multiplier * 3}
        :double_word -> {score + points, multiplier * 2}
        :triple_letter -> {score + (points * 3), multiplier}
        :double_letter -> {score + (points * 2), multiplier}
        _ -> {score + points, multiplier}
      end
    end)

    base_score * word_multiplier
  end

  defp calculate_horizontal_word_score(assigns, row, col) do
    word = get_horizontal_word_at(assigns, row, col)
    if String.length(word) > 1 do
      calculate_word_score(assigns, :horizontal)
    else
      0
    end
  end

  defp calculate_vertical_word_score(assigns, row, col) do
    word = get_vertical_word_at(assigns, row, col)
    if String.length(word) > 1 do
      calculate_word_score(assigns, :vertical)
    else
      0
    end
  end

  defp uses_center_square?(placed_tiles) do
    Enum.any?(placed_tiles, fn {{row, col}, _} ->
      row == 7 and col == 7
    end)
  end

  defp connects_to_existing_words?(board, placed_tiles) do
    Enum.any?(placed_tiles, fn {{row, col}, _} ->
      has_adjacent_tile?(board, row, col)
    end)
  end

  defp has_adjacent_tile?(board, row, col) do
    [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
    |> Enum.any?(fn {dx, dy} ->
      case get_in(board, [Access.at(row + dx), Access.at(col + dy)]) do
        nil -> false
        cell -> not is_nil(cell.letter)
      end
    end)
  end

  defp opposite_player(:player1), do: :player2
  defp opposite_player(:player2), do: :player1

  defp commit_tiles_to_board(assigns) do
    Enum.reduce(assigns.placed_tiles, assigns.board, fn {{row, col}, tile}, board ->
      List.update_at(board, row, fn row_list ->
        List.update_at(row_list, col, fn cell ->
          %{cell | letter: tile.letter, points: tile.points}
        end)
      end)
    end)
  end

  def serialize_board(board) do
    board
    |> Enum.map(fn row ->
      Enum.map(row, fn cell ->
        "#{cell.letter || "_"}:#{cell.points || 0}:#{cell.bonus || "normal"}"
      end)
      |> Enum.join("|")
    end)
    |> Enum.join("^")
  end

  def deserialize_board(board_string) do
    board_string
    |> String.split("^")
    |> Enum.map(fn row ->
      row
      |> String.split("|")
      |> Enum.map(fn cell ->
        [letter, points, bonus] = String.split(cell, ":")
        %{
          letter: if(letter == "_", do: nil, else: letter),
          points: String.to_integer(points),
          bonus: String.to_atom(bonus)
        }
      end)
    end)
  end

  defp check_game_over?(assigns) do
    tile_bag_empty? = Game.tile_bag_empty?()
    player1_empty? = Enum.empty?(assigns.rack_tiles)
    player2_empty? = Enum.empty?(assigns.rack_tiles_player2)

    (player1_empty? || player2_empty?) && tile_bag_empty?
  end

   @spec check_game_over(map()) :: boolean()
  defp check_game_over(assigns) do
    player1_rack_empty = Enum.empty?(assigns.rack_tiles)
    player2_rack_empty = Enum.empty?(assigns.rack_tiles_player2)
    tile_bag_empty = Game.tile_bag_empty?()

    (player1_rack_empty || player2_rack_empty) && tile_bag_empty
  end

  defp handle_game_over(socket) do
    final_score_player1 = calculate_final_score(
      socket.assigns.score_player1,
      socket.assigns.rack_tiles_player2
    )
    final_score_player2 = calculate_final_score(
      socket.assigns.score_player2,
      socket.assigns.rack_tiles
    )

    winner = cond do
      final_score_player1 > final_score_player2 -> "Player 1"
      final_score_player2 > final_score_player1 -> "Player 2"
      true -> "It's a tie"
    end

    socket
    |> assign(:final_score_player1, final_score_player1)
    |> assign(:final_score_player2, final_score_player2)
    |> assign(:game_over, true)
    |> put_flash(:info, "Game Over! #{winner} wins!")
  end

  # Calculate final score by subtracting remaining tile points
  defp calculate_final_score(current_score, remaining_tiles) do
    remaining_points = remaining_tiles
    |> Enum.map(& &1.points)
    |> Enum.sum()

    current_score - remaining_points
  end



  defp validate_move(assigns) do
    cond do
      map_size(assigns.placed_tiles) == 0 ->
        {:error, "No tiles placed"}

      not assigns.game_started and not uses_center_square?(assigns.placed_tiles) ->
        {:error, "First move must use the center square"}

      assigns.game_started and not connects_to_existing_words?(assigns.board, assigns.placed_tiles) ->
        {:error, "Words must connect to existing tiles"}

      true ->
        :ok
    end
  end

  defp get_formed_words(assigns) do
    try do
      main_word = get_word_at_placement(assigns)
      cross_words = get_cross_words(assigns)

      case main_word do
        "" ->
          {:error, "No valid word formed"}
        word when byte_size(word) < 2 ->
          {:error, "Word must be at least 2 letters long"}
        word ->
          {:ok, [word | cross_words]}
      end
    rescue
      e ->
        IO.puts("Error in get_formed_words: #{inspect(e)}") # Debug log
        {:error, "Error forming words"}
    end
  end

  # Update calculate_score to handle errors
  defp calculate_score(assigns) do
    try do
      main_word_score = calculate_word_score(assigns, assigns.current_direction)

      cross_words_score = assigns.placed_tiles
      |> Map.keys()
      |> Enum.map(fn {row, col} ->
        case assigns.current_direction do
          :horizontal -> calculate_vertical_word_score(assigns, row, col)
          :vertical -> calculate_horizontal_word_score(assigns, row, col)
          nil -> 0
        end
      end)
      |> Enum.sum()

      total_score = main_word_score + cross_words_score

      if total_score > 0 do
        {:ok, total_score}
      else
        {:error, "Invalid move - no points scored"}
      end
    rescue
      e ->
        IO.puts("Error in calculate_score: #{inspect(e)}") # Debug log
        {:error, "Error calculating score"}
    end
  end


end
