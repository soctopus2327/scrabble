defmodule Scrabble.Game.Board do
  def get() do
    # Return a list of tuples with row, column, and value for each tile
    [
      {1, 1, "3W"}, {1, 2, nil}, {1, 3, nil}, {1, 4, "2L"}, {1, 5, nil}, {1, 6, nil}, {1, 7, "3W"},
      {1, 8, nil}, {1, 9, "3W"}, {1, 10, nil}, {1, 11, nil}, {1, 12, "2L"}, {1, 13, nil}, {1, 14, nil}, {1, 15, "3W"},
      {2, 1, nil}, {2, 2, "2W"}, {2, 3, nil}, {2, 4, nil}, {2, 5, nil}, {2, 6, "3L"}, {2, 7, nil},
      {2, 8, nil}, {2, 9, nil}, {2, 10, "3L"}, {2, 11, nil}, {2, 12, nil}, {2, 13, nil}, {2, 14, "2W"}, {2, 15, nil},
      {3, 1, nil}, {3, 2, nil}, {3, 3, "2W"}, {3, 4, nil}, {3, 5, nil}, {3, 6, nil}, {3, 7, "2L"},
      {3, 8, nil}, {3, 9, "2L"}, {3, 10, nil}, {3, 11, nil}, {3, 12, nil}, {3, 13, "2W"}, {3, 14, nil}, {3, 15, nil},
      {8, 1, "3W"}, {8, 2, nil}, {8, 3, nil}, {8, 4, "2L"}, {8, 5, nil}, {8, 6, nil}, {8, 7, "3W"},
      {8, 8, nil}, {8, 9, "3W"}, {8, 10, nil}, {8, 11, nil}, {8, 12, nil}, {8, 13, nil}, {8, 14, nil}, {8, 15, "3W"},
      {15, 1, "3W"}, {15, 2, nil}, {15, 3, nil}, {15, 4, "2L"}, {15, 5, nil}, {15, 6, nil}, {15, 7, "3W"},
      {15, 8, nil}, {15, 9, "3W"}, {15, 10, nil}, {15, 11, nil}, {15, 12, "2L"}, {15, 13, nil}, {15, 14, nil}, {15, 15, "3W"}
    ]
    |> Enum.map(fn {row, col, value} ->
      # If the current position is the center (7,7), mark it as the start
      if row == 7 and col == 7 do
        {row, col, :start}  # Marking the starting point with :start
      else
        {row, col, value}
      end
    end)
  end

  def valid_coordinates?({row, col}) do
    row in 1..15 and col in 1..15
  end
end


defmodule Scrabblex.Games.Board do
  @multipliers %{
    "3W" => {:word, 3},
    "2W" => {:word, 2},
    "3L" => {:letter, 3},
    "2L" => {:letter, 2}
  }

  def new() do
    Scrabblex.Games.BoardLayout.get()
    |> Enum.reduce(%{}, fn {row, col, value}, acc ->
      Map.put(acc, {row, col}, value)
    end)
  end

  def get_multiplier({row, col}, board) when is_map_key(board, {row, col}) do
    case board[{row, col}] do
      nil -> {nil, 1}
      multiplier -> Map.get(@multipliers, multiplier, {nil, 1})
    end
  end

  def get_multiplier(_, _), do: {nil, 1}
end
