# # # defmodule Scrabble.Game do
# # #   @letter_points %{
# # #     "A" => 1, "B" => 3, "C" => 3, "D" => 2, "E" => 1,
# # #     "F" => 4, "G" => 2, "H" => 4, "I" => 1, "J" => 8,
# # #     "K" => 5, "L" => 1, "M" => 3, "N" => 1, "O" => 1,
# # #     "P" => 3, "Q" => 10, "R" => 1, "S" => 1, "T" => 1,
# # #     "U" => 1, "V" => 4, "W" => 4, "X" => 8, "Y" => 4,
# # #     "Z" => 10
# # #   }

# # #   def new_game do
# # #     %{
# # #       board: init_board(),
# # #       rack_tiles: draw_initial_tiles(),
# # #       score: 0
# # #     }
# # #   end

# # #   @on_load :init_tile_bag

# # #   def init_tile_bag do
# # #     :ets.new(:tile_bag, [:named_table, :public])
# # #     reset_tile_bag()
# # #     :ok
# # #   end

# # #   def reset_tile_bag do
# # #     :ets.delete_all_objects(:tile_bag)

# # #     # Insert all initial tiles into the bag
# # #     for {letter, points, count} <- @initial_tiles,
# # #         _ <- 1..count do
# # #       :ets.insert(:tile_bag, {letter, points})
# # #     end
# # #   end

# # #   def init_board do
# # #     for _row <- 1..15 do
# # #       for _col <- 1..15 do
# # #         %{
# # #           letter: nil,
# # #           points: 0,
# # #           bonus: get_bonus_type(_row, _col)
# # #         }
# # #       end
# # #     end
# # #   end

# # #   @spec draw_initial_tiles() :: [%{letter: <<_::8>>, points: 1 | 2 | 3 | 4}, ...]
# # #   def draw_initial_tiles do
# # #       tiles = [%{letter: "A", points: 1},
# # #       %{letter: "B", points: 3},
# # #       %{letter: "C", points: 3},
# # #       %{letter: "D", points: 2},
# # #       %{letter: "E", points: 1},
# # #       %{letter: "F", points: 4},
# # #       %{letter: "G", points: 2},
# # #       %{letter: "H", points: 2},
# # #       %{letter: "I", points: 2},
# # #       %{letter: "J", points: 2},
# # #       %{letter: "K", points: 2},
# # #       %{letter: "L", points: 2},
# # #       %{letter: "M", points: 2},
# # #       %{letter: "N", points: 2},
# # #       %{letter: "O", points: 2},
# # #       %{letter: "P", points: 2},
# # #       %{letter: "Q", points: 2},
# # #       %{letter: "R", points: 2},
# # #       %{letter: "S", points: 2},
# # #       %{letter: "T", points: 2},
# # #       %{letter: "U", points: 2},
# # #       %{letter: "V", points: 2},
# # #       %{letter: "W", points: 2},
# # #       %{letter: "X", points: 2},
# # #       %{letter: "Y", points: 2},
# # #       %{letter: "Z", points: 2},
# # #     ]
# # #     Enum.take_random(tiles, 7)
# # #   end

# # #   def replace_tiles(rack_tiles) do
# # #     missing_count = 7 - length(rack_tiles)

# # #     tiles = [%{letter: "A", points: 1},
# # #       %{letter: "B", points: 3},
# # #       %{letter: "C", points: 3},
# # #       %{letter: "D", points: 2},
# # #       %{letter: "E", points: 1},
# # #       %{letter: "F", points: 4},
# # #       %{letter: "G", points: 2},
# # #       %{letter: "H", points: 2},
# # #       %{letter: "I", points: 2},
# # #       %{letter: "J", points: 2},
# # #       %{letter: "K", points: 2},
# # #       %{letter: "L", points: 2},
# # #       %{letter: "M", points: 2},
# # #       %{letter: "N", points: 2},
# # #       %{letter: "O", points: 2},
# # #       %{letter: "P", points: 2},
# # #       %{letter: "Q", points: 2},
# # #       %{letter: "R", points: 2},
# # #       %{letter: "S", points: 2},
# # #       %{letter: "T", points: 2},
# # #       %{letter: "U", points: 2},
# # #       %{letter: "V", points: 2},
# # #       %{letter: "W", points: 2},
# # #       %{letter: "X", points: 2},
# # #       %{letter: "Y", points: 2},
# # #       %{letter: "Z", points: 2},
# # #     ]
# # #     new_tiles = Enum.take_random(tiles, missing_count)

# # #     rack_tiles ++ new_tiles
# # #   end

# # #   defp get_bonus_type(row, col) do
# # #     cond do
# # #       {row, col} in [{1, 1}, {1, 8}, {1, 15}, {8, 1}, {8, 15}, {15, 1}, {15, 8}, {15, 15}] -> :triple_word
# # #       {row, col} in [{2, 2}, {3, 3}, {4, 4}, {5, 5}, {11, 11}, {12, 12}, {13, 13}, {14, 14}, {2, 14}, {3, 13}, {4, 12}, {5, 11}, {11, 5}, {12, 4}, {13, 3}, {14, 2}] -> :double_word
# # #       {row, col} in [{1, 4}, {1, 12}, {4, 1}, {4, 8}, {4, 15}, {8, 4}, {8, 12}, {12, 1}, {12, 8}, {12, 15}, {15, 4}, {15, 12}, {7,7}, {9,7}, {7,9}, {9,9}] -> :triple_letter
# # #       {row, col} in [{2, 6}, {2, 10}, {6, 2}, {6, 6}, {6, 10}, {6, 14}, {10, 2}, {10, 6}, {10, 10}, {10, 14}, {14, 6}, {14, 10}] -> :double_letter
# # #       {row, col} in [{8,8}] -> :center
# # #       true -> :normal
# # #     end
# # #   end
# # #   defmodule ScrabbleScore do
# # #     @letter_values %{
# # #       "A" => 1, "B" => 3, "C" => 3, "D" => 2, "E" => 1, "F" => 4, "G" => 2,
# # #       "H" => 4, "I" => 1, "J" => 8, "K" => 5, "L" => 1, "M" => 3, "N" => 1,
# # #       "O" => 1, "P" => 3, "Q" => 10, "R" => 1, "S" => 1, "T" => 1, "U" => 1,
# # #       "V" => 4, "W" => 4, "X" => 8, "Y" => 4, "Z" => 10
# # #     }

# # #     def calculate_score(word) do
# # #       word
# # #       |> String.upcase()
# # #       |> String.graphemes()
# # #       |> Enum.map(&Map.get(@letter_values, &1, 0))
# # #       |> Enum.sum()
# # #     end
# # #   end

# # #   def get_letter_points(letter) do
# # #     @letter_points[letter]
# # #   end

# # #   def tile_bag_empty? do
# # #     :ets.info(:tile_bag, :size) == 0
# # #   end

# # # end



# defmodule Scrabble.Game do
#   @letter_points %{
#     "A" => 1, "B" => 3, "C" => 3, "D" => 2, "E" => 1,
#     "F" => 4, "G" => 2, "H" => 4, "I" => 1, "J" => 8,
#     "K" => 5, "L" => 1, "M" => 3, "N" => 1, "O" => 1,
#     "P" => 3, "Q" => 10, "R" => 1, "S" => 1, "T" => 1,
#     "U" => 1, "V" => 4, "W" => 4, "X" => 8, "Y" => 4,
#     "Z" => 10
#   }

#   # Define initial tiles with their counts
#   @initial_tiles [
#     {"A", 1, 9}, {"B", 3, 2}, {"C", 3, 2}, {"D", 2, 4},
#     {"E", 1, 12}, {"F", 4, 2}, {"G", 2, 3}, {"H", 4, 2},
#     {"I", 1, 9}, {"J", 8, 1}, {"K", 5, 1}, {"L", 1, 4},
#     {"M", 3, 2}, {"N", 1, 6}, {"O", 1, 8}, {"P", 3, 2},
#     {"Q", 10, 1}, {"R", 1, 6}, {"S", 1, 4}, {"T", 1, 6},
#     {"U", 1, 4}, {"V", 4, 2}, {"W", 4, 2}, {"X", 8, 1},
#     {"Y", 4, 2}, {"Z", 10, 1}
#   ]

#   # Create a list of all tiles with their correct frequencies
#   @all_tiles (for {letter, points, count} <- @initial_tiles,
#                   _ <- 1..count,
#                   do: %{letter: letter, points: points})

#   def new_game do
#     %{
#       board: init_board(),
#       rack_tiles: draw_initial_tiles(),
#       score: 0
#     }
#   end

#   def init_board do
#     for row <- 1..15 do
#       for col <- 1..15 do
#         %{
#           letter: nil,
#           points: 0,
#           bonus: get_bonus_type(row, col)
#         }
#       end
#     end
#   end

#   @spec draw_initial_tiles() :: [%{letter: String.t(), points: integer()}]
#   def draw_initial_tiles do
#     Enum.take_random(@all_tiles, 7)
#   end

#   def replace_tiles(rack_tiles) do
#     missing_count = 7 - length(rack_tiles)
#     new_tiles = Enum.take_random(@all_tiles, missing_count)
#     rack_tiles ++ new_tiles
#   end

#   defp get_bonus_type(row, col) do
#     cond do
#       {row, col} in [{1, 1}, {1, 8}, {1, 15}, {8, 1}, {8, 15}, {15, 1}, {15, 8}, {15, 15}] -> :triple_word
#       {row, col} in [{2, 2}, {3, 3}, {4, 4}, {5, 5}, {11, 11}, {12, 12}, {13, 13}, {14, 14},
#                      {2, 14}, {3, 13}, {4, 12}, {5, 11}, {11, 5}, {12, 4}, {13, 3}, {14, 2}] -> :double_word
#       {row, col} in [{1, 4}, {1, 12}, {4, 1}, {4, 8}, {4, 15}, {8, 4}, {8, 12}, {12, 1},
#                      {12, 8}, {12, 15}, {15, 4}, {15, 12}, {7,7}, {9,7}, {7,9}, {9,9}] -> :triple_letter
#       {row, col} in [{2, 6}, {2, 10}, {6, 2}, {6, 6}, {6, 10}, {6, 14}, {10, 2}, {10, 6},
#                      {10, 10}, {10, 14}, {14, 6}, {14, 10}] -> :double_letter
#       {row, col} in [{8,8}] -> :center
#       true -> :normal
#     end
#   end

#   def get_letter_points(letter) do
#     @letter_points[letter]
#   end

#   # Since we're not using ETS anymore, we can simplify tile bag empty check
#   def tile_bag_empty? do
#     false  # For now, assume bag never empties since we're reusing @all_tiles
#   end
# end
defmodule Scrabble.Game do
  @tile_distribution [
    {"A", 1, 9}, {"B", 3, 2}, {"C", 3, 2}, {"D", 2, 4}, {"E", 1, 12},
    {"F", 4, 2}, {"G", 2, 3}, {"H", 4, 2}, {"I", 1, 9}, {"J", 8, 1},
    {"K", 5, 1}, {"L", 1, 4}, {"M", 3, 2}, {"N", 1, 6}, {"O", 1, 8},
    {"P", 3, 2}, {"Q", 10, 1}, {"R", 1, 6}, {"S", 1, 4}, {"T", 1, 6},
    {"U", 1, 4}, {"V", 4, 2}, {"W", 4, 2}, {"X", 8, 1}, {"Y", 4, 2},
    {"Z", 10, 1}
  ]

  @board_size 15
  @bonus_squares %{
    triple_word: [{0, 0}, {0, 7}, {0, 14}, {7, 0}, {7, 14}, {14, 0}, {14, 7}, {14, 14}],
    double_word: [{1, 1}, {1, 13}, {2, 2}, {2, 12}, {3, 3}, {3, 11}, {4, 4}, {4, 10},
                  {10, 4}, {10, 10}, {11, 3}, {11, 11}, {12, 2}, {12, 12}, {13, 1}, {13, 13}],
    triple_letter: [{1, 5}, {1, 9}, {5, 1}, {5, 5}, {5, 9}, {5, 13},
                    {9, 1}, {9, 5}, {9, 9}, {9, 13}, {13, 5}, {13, 9}],
    double_letter: [{0, 3}, {0, 11}, {2, 6}, {2, 8}, {3, 0}, {3, 7}, {3, 14},
                    {6, 2}, {6, 6}, {6, 8}, {6, 12}, {7, 3}, {7, 11},
                    {8, 2}, {8, 6}, {8, 8}, {8, 12}, {11, 0}, {11, 7}, {11, 14},
                    {12, 6}, {12, 8}, {14, 3}, {14, 11}]
  }

  # The tile bag is stored in the process dictionary
  @tile_bag_key :scrabble_tile_bag

  def new_game do
    # Initialize tile bag
    tile_bag = initialize_tile_bag()
    Process.put(@tile_bag_key, tile_bag)

    %{
      board: init_board(),
      rack_tiles: draw_tiles(7),
      rack_tiles_player2: draw_tiles(7),
      game_id: Ecto.UUID.generate()
    }
  end

  def init_board do
    board = for row <- 0..(@board_size - 1) do
      for col <- 0..(@board_size - 1) do
        %{
          letter: nil,
          points: nil,
          bonus: get_bonus_at(row, col)
        }
      end
    end

    # Set center square
    List.update_at(board, 7, fn row ->
      List.update_at(row, 7, fn cell -> %{cell | bonus: :center} end)
    end)
  end

  def draw_tiles(count) do
    tile_bag = Process.get(@tile_bag_key, [])
    {drawn_tiles, remaining_tiles} = Enum.split(tile_bag, count)
    Process.put(@tile_bag_key, remaining_tiles)
    drawn_tiles
  end

  def replace_tiles(used_tiles) do
    new_tiles = draw_tiles(length(used_tiles))

    # Put used tiles back in the bag and shuffle
    tile_bag = Process.get(@tile_bag_key, [])
    updated_bag = (tile_bag ++ used_tiles) |> Enum.shuffle()
    Process.put(@tile_bag_key, updated_bag)

    new_tiles
  end

  def tile_bag_empty? do
    Process.get(@tile_bag_key, []) == []
  end

  defp initialize_tile_bag do
    @tile_distribution
    |> Enum.flat_map(fn {letter, points, count} ->
      List.duplicate(%{letter: letter, points: points}, count)
    end)
    |> Enum.shuffle()
  end

  defp get_bonus_at(row, col) do
    cond do
      {row, col} in @bonus_squares.triple_word -> :triple_word
      {row, col} in @bonus_squares.double_word -> :double_word
      {row, col} in @bonus_squares.triple_letter -> :triple_letter
      {row, col} in @bonus_squares.double_letter -> :double_letter
      row == 7 and col == 7 -> :center
      true -> :normal
    end
  end

  # Add any serialization helpers if needed
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
end

# defmodule Scrabble.Game do
#   use Ecto.Schema
#   import Ecto.Changeset

#   schema "games" do
#     field :code, :string
#     belongs_to :creator, Scrabble.User, foreign_key: :creator_id

#     timestamps()
#   end

#   def changeset(game, attrs) do
#     game
#     |> cast(attrs, [:code, :creator_id])
#     |> validate_required([:code, :creator_id])
#     |> unique_constraint(:code)
#   end
# end
